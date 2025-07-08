# school_student_performance_q3
## 📚 Student Success Q3 Analysis
### Project Overview
At a school in Oregon, I was tasked with identifying trends and patterns using attendance, demographic, and student success data from Quarter 3 in order to inform more targeted academic interventions and trainings. This correlational/descriptive analysis was conducted using data derived from Synergy, cleaned in Google Sheets, analyzed in both [SQL](https://github.com/kmromrell/school_student_performance_q3/blob/main/school_data_queries.sql) and R ([exploration](https://github.com/kmromrell/school_student_performance_q3/blob/main/student_performance_exploration.R) and [analysis](https://github.com/kmromrell/school_student_performance_q3/blob/main/student_performance_analysis_code.Rmd)), and reported in [Google Slides](https://docs.google.com/presentation/d/1Ud1r2N88FRdj8OlvtDZVQp6WRiUPfX5vLzeP5yJZW00/edit?usp=sharing) (report anonymized for school confidentiality). 

### Driving Questions:
* Which student factors are the largest predictors of student success?
* What should the school do to improve student outcomes?

### Data Cleaning and Analysis Steps
1. **Norming Data in Google Sheets**: Standardized table headers, cleaned student records, handled NULL values, and exported data for SQL processing
2. **Initial Data Exploration in SQL**: Explored norms in grades overall, by department, by class type, etc.
3. **Data Cleaning in SQL**: Created R-friendly table, merging necessary data from 10 tables and generating new columns to identify absence/trady per period, numeric and ordinal measures of attendance, etc.
4. **Data Aggregation in SQL**: Summarized grades, attendance, and pass rates by demographics, course types, and departments
5. **Exploratory/Predictive Analysis in R**: Explored data via ANOVAs and basic regressions, ran multiple linear regressions to identify most predictive model, calculated relative importance of each student factor
6. **Data Visualization in R**: Created dashboards and faceted plots to illustrate trends across absence levels and student groups
7. **Report in Google Slides**: Compiled visuals and findings into a  Google Slides report to recommend next steps, demonstrate patterns, and guide staff discussions/interventions

### SQL Functions Used: 
* **SQL Basics**: `SELECT`, `FROM`, `WHERE`, `ORDER BY`, `LIMIT`, `DISTINCT`, `AS`, basic operators and arithemetic
* **Aggregation**: `GROUP BY`, `HAVING`, `COUNT()`, `AVG()`, `ROUND()`, `WITH ROLLUP`
* **Joins/Combination Queries**: `INNER JOIN`, `LEFT JOIN`, `USING()`, subqueries in `SELECT`, `FROM`, and `WHERE` clauses
* **Conditional Expressions**: `CASE WHEN ... THEN ... ELSE ... END`, `COALESCE()`, `IS NULL`, `IS NOT NULL`
* **Table Design**: `CREATE TABLE AS`, `ALTER TABLE ADD COLUMN`, `GENERATED ALWAYS AS () STORED`

### R Functions Used:  
* **Data Cleaning and Manipulation**: `filter()`, `mutate()`, `select()`, `left_join()`, `arrange()`, `group_by()`, `rename()`, `case_when()`, `if_else()`, `as.factor()`, `as.character()`, `round()`, `is.na()`  
* **Data Summarization and Aggregation**: `summarize()`, `n()`, `mean()`, `sd()`, `min()`, `max()`, `count()`  
* **Statistical Modeling and Tests**: `lm()`, `aov()`, `summary()`, `anova()`, `coef()`, `confint()`, `broom::tidy()`, `broom::glance()`  
* **Relative Importance Analysis**: `relaimpo::calc.relimp()`, `relaimpo::boot.relimp()`, `summary()`
* **Visualization and Plotting**: `ggplot()`, `aes()`, `geom_point()`, `geom_bar()`, `geom_col()`, `geom_errorbar()`, `geom_boxplot()`, `geom_line()`, `geom_text()`, `facet_wrap()`, `facet_grid()`, `labs()`, `theme()`, `scale_fill_manual()`, `scale_color_manual()`, `coord_flip()`, patchwork operators (`+`, `/`), `ggsave()`  
* **Miscellaneous / Helper Functions**: `library()`, `print()`, `head()`, `str()`, `%>%`, `glimpse()`, `unique()`, `levels()`, `table()`  

### Major Findings:
1. Time with teacher (mostly absences, but also tardies) is largest predictor of grades/pass rates
2. Averages, norms, and predictors varied by class type (see report for details) 
    * Shared largest predictors: support seminar/class absences
    * Avg. core class grades are [redacted] grade point less than non-core avg
3. Support needs had a [redacted] relationship with student success, differing by core/non-core classes

### Recommendations:
1. Treat support seminar absences as attendance
    * Currently, support seminar absences/tardies aren’t penalized the same way normal classes are (e.g., sports, detention, parking, etc.), suggesting to students that they're less important
    * Enforcing support seminar attendance would align with the finding that support seminar attendance is an even larger predictor of success than normal class attendance
2. Increase communications with parents about the importance of attendance for student success
    * Post-COVID, student culture still deprioritizes physical presence
    * Most absences are parent excused, so work must include parents -- consider reinstating the attendance task force with parents
3. Focus teacher trainings on targeted demographics by core vs. non-core subjects (most-needed demographics are redacted for confidentiality)
