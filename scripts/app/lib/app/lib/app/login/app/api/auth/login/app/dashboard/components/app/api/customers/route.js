import { query } from '@/app/lib/db';

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const page = parseInt(searchParams.get('page')) || 1;
    const limit = parseInt(searchParams.get('limit')) || 10;
    const search = searchParams.get('search') || '';
    const status = searchParams.get('status') || '';

    const offset = (page - 1) * limit;

    let whereClause = '';
    const params = [];

    if (search) {
      whereClause += ` AND (c.full_name LIKE ? OR c.customer_code LIKE ? OR c.username LIKE ?)`;
      params.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }

    if (status) {
      whereClause += ` AND c.status = ?`;
      params.push(status);
    }

    // Get total count
    const countQuery = `
      SELECT COUNT(*) as total 
      FROM customers c
      WHERE 1=1 ${whereClause}
    `;

    // Get data
    const dataQuery = `
      SELECT 
        c.*,
        p.name as package_name,
        p.price as package_price,
        DATEDIFF(c.expiration_date, CURDATE()) as days_remaining,
        (SELECT SUM(amount) FROM payments WHERE customer_id = c.id) as total_paid
      FROM customers c
      LEFT JOIN packages p ON c.package_id = p.id
      WHERE 1=1 ${whereClause}
      ORDER BY c.id DESC
      LIMIT ? OFFSET ?
    `;

    const [countResult] = await query(countQuery, params);
    const total = countResult[0]?.total || 0;

    const customers = await query(dataQuery, [...params, limit, offset]);

    return Response.json({
      success: true,
      data: customers,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });

  } catch (error) {
    console.error('Error fetching customers:', error);
    return Response.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

export async function POST(request) {
  try {
    const data = await request.json();
    
    // Generate customer code
    const date = new Date();
    const year = date.getFullYear().toString().slice(-2);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    
    // Get last customer number for this month
    const lastCustomer = await query(
      `SELECT customer_code FROM customers 
       WHERE customer_code LIKE ? 
       ORDER BY id DESC LIMIT 1`,
      [`CUST${year}${month}%`]
    );

    let nextNumber = 1;
    if (lastCustomer.length > 0) {
      const lastCode = lastCustomer[0].customer_code;
      const lastNum = parseInt(lastCode.slice(-4));
      nextNumber = lastNum + 1;
    }

    const customerCode = `CUST${year}${month}${nextNumber.toString().padStart(4, '0')}`;
    
    // Calculate expiration date
    const packageData = await query(
      'SELECT validity_days FROM packages WHERE id = ?',
      [data.package_id]
    );
    
    const validityDays = packageData[0]?.validity_days || 30;
    const expirationDate = new Date();
    expirationDate.setDate(expirationDate.getDate() + validityDays);

    const result = await query(
      `INSERT INTO customers (
        customer_code, full_name, email, phone, address,
        package_id, username, password, ip_address, mac_address,
        status, registration_date, expiration_date
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURDATE(), ?)`,
      [
        customerCode,
        data.full_name,
        data.email,
        data.phone,
        data.address,
        data.package_id,
        data.username,
        data.password,
        data.ip_address,
        data.mac_address,
        'active',
        expirationDate.toISOString().split('T')[0]
      ]
    );

    // Also add to radius table if needed
    await query(
      `INSERT INTO radius_users (username, password, customer_id, package_id)
       VALUES (?, ?, ?, ?) 
       ON DUPLICATE KEY UPDATE password = ?`,
      [
        data.username,
        data.password,
        result.insertId,
        data.package_id,
        data.password
      ]
    );

    return Response.json({
      success: true,
      message: 'Customer created successfully',
      data: { id: result.insertId, customer_code: customerCode }
    });

  } catch (error) {
    console.error('Error creating customer:', error);
    return Response.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}