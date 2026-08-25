# Airline Commercial & Operations Analytics — SQL

A self-directed SQL case study designed to answer **40 business questions** across revenue, route performance, airline reliability, passenger segments, booking conversion, delays, cancellations, and operational risk.

> **Portfolio status:** Query framework completed. The repository does not yet contain the source dataset or executed result outputs, so this project demonstrates analytical design and SQL logic—not validated business findings.

## Business Objective

Build a reusable analytical layer that helps airline stakeholders evaluate:

- revenue mix and unrealized booking value
- airline and route performance
- delays, cancellations, and network reliability
- passenger and ticket-class segments
- route-expansion opportunities and operational risk

## Analytical Scope

| Decision area | Example questions |
|---|---|
| Commercial performance | Which airlines, routes, continents, and ticket classes drive revenue? |
| Customer strategy | Which passenger segments contribute the most value? |
| Operations | Which airlines and routes have the highest disruption rates? |
| Growth | Where is demand relatively low but average ticket value high? |
| Risk | Which routes combine elevated delay and cancellation rates? |

## Repository Contents

- [`airline_analytics_solved_questions.sql`](./airline_analytics_solved_questions.sql) — 40 documented SQL analyses
- [`README.md`](./README.md) — recruiter-facing project summary

## Data Model Assumptions

The SQL uses three conceptual tables:

- **flights** — airline, route, status, duration, and flight date
- **tickets** — booking status, class, price, seat, and booking date
- **passengers** — nationality, region, gender, and age

Relationships:

- `flights.flight_id = tickets.flight_id`
- `tickets.passenger_id = passengers.passenger_id`

The column names and SQL dialect must be aligned with the actual source database before execution.

## SQL Skills Demonstrated

- multi-table `LEFT JOIN`
- reusable CTE-based analytical layer
- conditional aggregation and business-rule filters
- window functions: `LAG`, `DENSE_RANK`, and share-of-total calculations
- date aggregation with `DATE_TRUNC`
- segmentation with `CASE`
- data-quality safeguards using `NULLIF`
- operational and commercial KPI design

## Important Business Rules

- Revenue includes only **confirmed bookings**, unless a query explicitly states otherwise.
- Flights use distinct `flight_id` counts to reduce duplication after ticket-level joins.
- Cancelled-booking impact is an **estimate**, not accounting profit.
- “Profitability” queries currently calculate revenue because cost data is unavailable.
- The network-health score is an illustrative composite and requires stakeholder-approved weights.

## Validation Required Before Claiming Results

1. Replace assumed field names with the actual schema.
2. Confirm the SQL dialect supports `FILTER`, `DATE_TRUNC`, and `STDDEV`.
3. Test join cardinality and duplicate counts.
4. Reconcile confirmed-ticket revenue to a source total.
5. Review nulls, invalid statuses, price outliers, and date coverage.
6. Save executed outputs before publishing findings.

## Next Development Milestone

Add a reproducible dataset/schema, an ER diagram, validated query outputs, three to five quantified findings, and dashboard screenshots. Those additions will convert this SQL framework into a complete recruiter-ready case study.

## Tools

SQL · CTEs · Joins · Window Functions · KPI Design · Data Validation
