/*
# Hacer una vista para poder conocer el producto
# mas vendido por sucursal en cada mes por año
 */
DROP TEMPORARY TABLE IF EXISTS monthly_sales;

DROP TEMPORARY TABLE IF EXISTS maximum_monthly_sales;

DROP TEMPORARY TABLE IF EXISTS monthly_sales_report;

CREATE TEMPORARY TABLE monthly_sales (
    id INTEGER NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (id),
    INDEX (id)
) (
    SELECT
        year (purchase.created_at) AS `year`,
        MONTH (purchase.created_at) AS `month`,
        customer.branch_id,
        purchase_product.product_id,
        count(purchase_product.product_id) AS total_sales
    FROM
        purchase_product
        INNER JOIN purchase ON purchase_product.purchase_id = purchase.id
        INNER JOIN customer ON purchase.customer_id = customer.id
    WHERE
        purchase.status = 'pagado'
        AND purchase.deleted_at IS NULL
        AND customer.deleted_at IS NULL
    GROUP BY
        `year`,
        `month`,
        customer.branch_id,
        purchase_product.product_id
    ORDER BY
        `year` DESC,
        `month` ASC,
        customer.branch_id,
        total_sales DESC
);

/**
 * The below view helps to get top quantity of sold products per store/month
 * and resolve the issue with multiple products with same quantity.
 * Eg. A store with 2 o more products with the highest number of items sold
 */
CREATE TEMPORARY TABLE maximum_monthly_sales (
    id INTEGER NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (id),
    INDEX (id)
) (
    SELECT
        monthly_sales.year,
        monthly_sales.month,
        monthly_sales.branch_id,
        max(monthly_sales.total_sales) AS maximum_monthly_sale
    FROM
        monthly_sales
    GROUP BY
        monthly_sales.year,
        monthly_sales.month,
        monthly_sales.branch_id
);

CREATE TEMPORARY TABLE monthly_sales_report (
    id INTEGER NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (id),
    INDEX (id)
) (
    SELECT
        maximum_monthly_sales.year `Year`,
        MONTHNAME (
            CONCAT (
                maximum_monthly_sales.year,
                '-',
                maximum_monthly_sales.month,
                '-01'
            )
        ) `Month`,
        branch.id `Store Identifier`,
        branch.name `Store Name`,
        monthly_sales.product_id `Product Identifier`,
        product.`name` `Product Name`,
        maximum_monthly_sales.maximum_monthly_sale `Sold Products`
    FROM
        maximum_monthly_sales
        INNER JOIN branch ON branch.id = maximum_monthly_sales.branch_id
        INNER JOIN monthly_sales ON maximum_monthly_sales.year = monthly_sales.year
        AND maximum_monthly_sales.month = monthly_sales.month
        AND maximum_monthly_sales.branch_id = monthly_sales.branch_id
        AND maximum_monthly_sales.maximum_monthly_sale = monthly_sales.total_sales
        INNER JOIN product ON monthly_sales.product_id = product.id
    WHERE
        branch.deleted_at IS NULL
        AND product.deleted_at IS NULL
);

SELECT
    *
FROM
    monthly_sales_report;
