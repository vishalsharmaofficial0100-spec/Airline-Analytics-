# Airline Analytics SQL Project

This repository packages a small SQL portfolio project in a clean GitHub-style structure, similar to the example image you shared.

## Project Objective

The goal of this project is to solve airline analytics business questions using SQL and document the approach clearly enough for review, practice, and portfolio use.

## Repository Files

- `airline_analytics_solved_questions.sql` - solved SQL questions for the airline analytics problem
- `README.md` - project overview and step-by-step solution process

## Problem-Solving Steps

### 1. Understand the business problem

Start by reading the questions carefully and identifying what the business wants to know. Typical airline analytics questions include:

- which airline performs best
- which routes generate the most revenue
- how delays and cancellations affect operations
- what passenger segments are most valuable

Convert each business question into a simple data question before writing SQL.

### 2. Understand the dataset structure

Review the tables and fields before solving anything. For this project, the assumed tables are:

- `flights`
- `tickets`
- `passengers`

Check how the tables connect:

- `flights.flight_id` joins to `tickets.flight_id`
- `tickets.passenger_id` joins to `passengers.passenger_id`

This step prevents wrong joins and duplicate results.

### 3. Check the important columns

Identify the columns needed for analysis:

- airline
- departure and destination countries or continents
- status
- duration
- ticket class
- ticket price
- booking status
- passenger age, gender, and nationality
- date fields

At this stage, confirm the column names in your actual database and adjust the SQL if names differ.

### 4. Clean the logic before analysis

Before solving the business questions, define the business rules clearly:

- use confirmed tickets for revenue unless stated otherwise
- define delayed, cancelled, and on-time flights correctly
- decide which date column should be used for time-based analysis
- avoid counting the same ticket or passenger more than once by mistake

Good SQL starts with correct assumptions.

### 5. Break the work into smaller questions

Instead of solving the entire business problem at once, split it into small tasks such as:

- total flights by airline
- delayed flights by airline
- revenue by airline or route
- booking trends by date
- passenger mix by class, gender, or region

This makes the project easier to test and explain.

### 6. Write the base query

Create a base query or CTE to combine the required tables and standardize the fields used in later analysis. This is useful because:

- repeated joins are reduced
- logic stays consistent
- later queries become easier to read

In this project, the SQL begins with a base CTE for that reason.

### 7. Solve one metric at a time

Build each answer separately. Common SQL techniques include:

- `COUNT()` for totals
- `SUM()` for revenue
- `AVG()` for average duration or price
- `GROUP BY` for airline, route, or passenger segments
- `CASE WHEN` for status-based logic
- `JOIN` for combining business entities
- `ORDER BY` for ranking results
- CTEs for readability

Focus on correctness before trying to make the query shorter.

### 8. Validate each result

After writing a query, verify that the result makes sense:

- are totals unexpectedly high because of duplicate joins
- does revenue include cancelled bookings by mistake
- are filters excluding important rows
- do the date ranges match the business question

Validation is part of solving, not an optional final step.

### 9. Interpret the output as business insight

The final goal is not only to return rows. It is to explain what the rows mean. For example:

- one airline may have the highest revenue but also the most delays
- one route may be profitable but unstable
- business-class passengers may contribute a larger share of revenue

This is the difference between SQL practice and business analysis.

### 10. Organize the project as a portfolio repository

To make the work look professional, package it like a real project:

- keep the solved SQL in a clearly named file
- add a README
- explain the business objective
- explain the solving method
- keep the folder structure simple

That is the structure created in this repository.

## What This Local Repository Contains

This local repository has been prepared with:

- a project folder
- the solved SQL file
- a README with the end-to-end solution process
- local Git repository setup

## Recommended Next Steps

To improve the project further, you can add:

- a dataset file if available
- an ER diagram or schema image
- a questions file listing each business prompt
- a short summary of findings from the SQL results

These additions will make the repository closer to the example image and stronger for a portfolio.
