/*
# Hacer una vista para poder conocer el producto
# mas vendido por sucursal en cada mes por año
 */
DROP TEMPORARY TABLE IF EXISTS customers_overview;

/*
 * Support view (quick search)
 */
CREATE TEMPORARY TABLE customers_overview (
    id INTEGER NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (id),
    INDEX (id)
) (
    SELECT
        branch.id `branch_id`,
        branch.name `branch_name`,
        customer.id `customer_id`,
        customer.name `customer_name`,
        customer.age `customer_age`,
        customer.email `customer_email`,
        Sum(
            CASE
                WHEN purchase.status = 'vigente' THEN purchase.total
                ELSE 0
            END
        ) vigente_sum,
        sum(
            CASE
                WHEN purchase.status = 'vigente' THEN 1
                ELSE 0
            END
        ) vigente_total,
        Sum(
            CASE
                WHEN purchase.status = 'pagado' THEN purchase.total
                ELSE 0
            END
        ) pagado_sum,
        sum(
            CASE
                WHEN purchase.status = 'pagado' THEN 1
                ELSE 0
            END
        ) pagado_total,
        Sum(
            CASE
                WHEN purchase.status = 'cancelado' THEN purchase.total
                ELSE 0
            END
        ) cancelado_sum,
        sum(
            CASE
                WHEN purchase.status = 'cancelado' THEN 1
                ELSE 0
            END
        ) cancelado_total
    FROM
        branch
        INNER JOIN customer ON branch.id = customer.branch_id
        INNER JOIN purchase ON customer.id = purchase.customer_id
    WHERE
        branch.deleted_at IS NULL
        AND customer.deleted_at IS NULL
        AND purchase.deleted_at IS NULL
    GROUP BY
        purchase.customer_id
);

drop PROCEDURE if EXISTS store_customers_overview;

CREATE PROCEDURE store_customers_overview (IN branch_id bigint) BEGIN
SELECT
    customers_overview.branch_id `Branch Identifier`,
    customers_overview.branch_name `Branch Name`,
    customers_overview.customer_id `Customer Identifier`,
    customers_overview.customer_name `Customer Name`,
    customers_overview.customer_age `Customer Age`,
    customers_overview.customer_email `Customer Email`,
    CONCAT (
        '$',
        FORMAT (customers_overview.vigente_sum, 2, 'en_US')
    ) `Sumatory sales - Vigente`,
    FORMAT (customers_overview.vigente_total, 0, 'en_US') `Total sales - Vigente`,
    CONCAT (
        '$',
        FORMAT (customers_overview.pagado_sum, 2, 'en_US')
    ) `Sumatory sales - Pagado`,
    FORMAT (customers_overview.pagado_total, 0, 'en_US') `Total sales - Pagado`,
    CONCAT (
        '$',
        FORMAT (customers_overview.cancelado_sum, 2, 'en_US')
    ) `Sumatory sales - Cancelado`,
    FORMAT (customers_overview.cancelado_total, 0, 'en_US') `Total sales - Cancelado`,
    CASE
        WHEN customers_overview.pagado_total > customers_overview.cancelado_total THEN 'excelent'
        ELSE 'No excelent'
    END AS `client_marking`
FROM
    customers_overview
Where
    customers_overview.branch_id = branch_id;

END;
