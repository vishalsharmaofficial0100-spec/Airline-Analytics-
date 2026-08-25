# Airline Commercial & Operations Analytics | SQL

A self-directed SQL case study covering **40 business questions** across revenue, routes, airline performance, passenger segments, bookings, delays, cancellations, and operational risk.

**Project status:** The SQL analysis framework is complete. Dataset files and executed results are not included, so this repository demonstrates analytical thinking, KPI design, and SQL capability rather than validated business findings.

## Business Goal

Create a reusable analytical framework that helps airline stakeholders answer four questions:

- Where does revenue come from?
- Which airlines and routes perform best?
- Where are delays, cancellations, and booking losses concentrated?
- Which customer segments and routes present growth opportunities?

## Analysis Areas

| Area | Questions addressed |
|---|---|
| Revenue | Revenue by airline, route, continent, class, and passenger segment |
| Customer | Passenger mix, age bands, nationality, and business-class adoption |
| Operations | On-time performance, disruptions, duration consistency, and bottlenecks |
| Growth | Route-expansion candidates and underserved high-value markets |
| Risk | Cancellation impact, pending-booking age, and route-level risk flags |

## Repository Files

- [`airline_analytics_solved_questions.sql`](./airline_analytics_solved_questions.sql) — 40 documented SQL analyses
- [`README.md`](./README.md) — business context, assumptions, and validation plan

## Data Model

The queries use three conceptual tables:

- **flights:** airline, route, status, duration, and flight date
- **tickets:** booking status, class, price, seat, and booking date
- **passengers:** nationality, region, gender, and age

Relationships:

```text
flights.flight_id = tickets.flight_id
tickets.passenger_id = passengers.passenger_id
```

Field names and SQL syntax must be aligned with the source database before execution.

## SQL Techniques

- CTEs and multi-table joins
- conditional aggregation
- window functions such as `LAG` and `DENSE_RANK`
- share-of-total and ranking calculations
- date-based trend analysis
- customer and route segmentation
- null and divide-by-zero safeguards
- commercial and operational KPI design

## Business Rules and Limitations

- Revenue uses confirmed bookings unless stated otherwise.
- Flights are counted using distinct `flight_id` values to reduce duplication after joins.
- Cancellation impact represents estimated lost booking value, not accounting profit.
- “Profitability” currently refers to revenue because cost data is unavailable.
- The network-health score is illustrative and requires stakeholder-approved weights.

## Validation Plan

Before publishing findings:

1. Match the assumed fields to the actual schema.
2. Confirm SQL-dialect compatibility.
3. Test join cardinality and duplicate counts.
4. Reconcile confirmed-booking revenue with source totals.
5. Review nulls, invalid statuses, outliers, and date coverage.
6. Save query outputs and document verified findings.

## Next Step

Add a reproducible dataset, ER diagram, executed query outputs, quantified insights, and dashboard screenshots to complete the case study.

**Tools:** SQL · CTEs · Joins · Window Functions · KPI Design · Data Validation
