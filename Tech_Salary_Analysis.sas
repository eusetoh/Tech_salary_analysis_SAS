DATA tech_salaries;
    INFILE '/home/u64116514/global_tech_salary.txt' DSD FIRSTOBS=2; /*tells you where to read the file*/
    INPUT /* specifies the variable names and number of characters/digits*/
        work_year : 4.
        experience_level : $2.
        employment_type : $2.
        job_title : $50.
        salary : BEST8.
        salary_currency : $3.
        salary_in_usd : BEST8.
        employee_residence : $2.
        remote_ratio : 3.
        company_location : $2.
        company_size : $1.;
RUN;

PROC MEANS DATA=tech_salaries;
    VAR salary_in_usd;
RUN;

DATA tech_salaries;
    SET tech_salaries;  /* Read in the existing dataset */
    monthly_salary_usd = salary_in_usd / 12;  /* Calculate monthly salary */
RUN;

PROC MEANS DATA=tech_salaries;
    VAR monthly_salary_usd;
RUN;

PROC MEANS DATA=tech_salaries MEAN;
    CLASS job_title;  /* Class helps to group it btGroup by job title */
    VAR monthly_salary_usd;  /* Calculate the mean for monthly salary in USD */
RUN;

PROC MEANS DATA=tech_salaries MEAN;
    CLASS experience_level;  /* Class helps to group it btGroup by job title */
    VAR monthly_salary_usd;  /* Calculate the mean for monthly salary in USD */
RUN;

PROC ANOVA DATA=tech_salaries;
    CLASS experience_level;  /* Categorical predictor */
    MODEL monthly_salary_usd = experience_level;  /* Dependent variable */
   	MEANS experience_level/tukey;
RUN;
/* 1 way ANOVA shows that both experience level is a significant predictor of salary*/

PROC MEANS DATA=tech_salaries MEAN;
    CLASS company_size;  /* Class helps to group it btGroup by job title */
    VAR monthly_salary_usd;  /* Calculate the mean for monthly salary in USD */
RUN;
/*medium companies seem to pay more than large companies!*/

PROC ANOVA DATA=tech_salaries;
    CLASS experience_level company_size;  /* Two categorical predictors */
    MODEL monthly_salary_usd = experience_level company_size experience_level*company_size;  /* Dependent variable and interaction */
    MEANS experience_level company_size / TUKEY;  /* Post-hoc Tukey test */
RUN;
/* 2 way ANOVA shows that both compna size and experience levels are significant, but interaction effect not significant*/

/* assumption check for normality - violated*/

PROC UNIVARIATE DATA=tech_salaries NORMAL;
    VAR monthly_salary_usd;
    CLASS experience_level;
RUN;

/* assumption check for homogenity of variance (homoscedascity) - no evidence of violated p = 0.06 */
PROC GLM DATA=tech_salaries;
    CLASS experience_level;
    MODEL monthly_salary_usd = experience_level;
    MEANS experience_level / HOVTEST=LEVENE;  /* Levene's test for homogeneity of variance */
RUN;


