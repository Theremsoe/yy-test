/*
 * Hacer un query que muestre
 * las 5 categorías menos vendidas de una sucursal con id = 375
 */
SELECT
	category.id AS `Category ID`,
	category.name AS `Category Name`,
	sum(seeker.number_of_sales) AS `Total Sales`
FROM
	category
	INNER JOIN product ON category.id = product.category_id
	JOIN (
		SELECT
			purchase_product.product_id AS product_id,
			count(purchase_product.product_id) AS number_of_sales
		FROM
			customer
			INNER JOIN purchase ON customer.id = purchase.customer_id
			INNER JOIN purchase_product ON purchase.id = purchase_product.purchase_id
		WHERE
			purchase.status = 'pagado'
			AND customer.branch_id in (375)
			AND customer.deleted_at IS NULL
			AND purchase.deleted_at IS NULL
		GROUP BY
			purchase_product.product_id
		ORDER BY
			number_of_sales ASC
	) AS seeker ON seeker.product_id = product.id
WHERE
	category.deleted_at IS NULL
GROUP BY
	category.id
ORDER BY
	`Total Sales`;
