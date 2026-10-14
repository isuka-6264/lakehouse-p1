SELECT c.custkey, c.name, sum(l.extendedprice * (1 - l.discount)) AS revenue,
       c.acctbal, n.name AS nation, c.address, c.phone, c.comment
FROM __S__.customer AS c
JOIN __S__.orders   AS o ON c.custkey = o.custkey
JOIN __S__.lineitem AS l ON l.orderkey = o.orderkey
JOIN __S__.nation   AS n ON c.nationkey = n.nationkey
WHERE o.orderdate >= DATE '1993-10-01' AND o.orderdate < DATE '1994-01-01'
  AND l.returnflag = 'R'
GROUP BY c.custkey, c.name, c.acctbal, n.name, c.address, c.phone, c.comment
ORDER BY revenue DESC
LIMIT 20;
