### EDA

-- I'm going to explore the data and find trends or patterns or anything interesting.

Select*
from layoff_stagging2;

#Looking at Percentage to see how big these layoffs were

Select max(total_laid_off) , max(percentage_laid_off)
from layoff_stagging2;

 #Which companies had 1 which is basically 100 percent of they company laid off
 
Select*                #count(*)
from layoff_stagging2
where percentage_laid_off = 1
order by total_laid_off desc;
# 115 and look  mostly like startups who all went out of business during this time


# let's see how big some of these companies are by oredering by funcs_raised_millions
Select*
from layoff_stagging2
where percentage_laid_off = 1
order by funds_raised_millions desc;
#Britishvolt is the company that raised the most and went completelly off (over 2 billion usd)


#Companies with the biggest single Layoff
select company, sum(total_laid_off)
from layoff_stagging2
group by company
order by 2 desc;
#Amazon with (18150 laid_off)


Select min(`date`), max(`date`)
from layoff_stagging2; 
# this are only the data From 2020 to 2023

#by industry
select industry, sum(total_laid_off)
from layoff_stagging2
group by industry
order by 2 desc;

select company, industry, sum(total_laid_off)
from layoff_stagging2
where industry = 'Finance'
group by company
order by 3 desc;

#by country
select country, sum(total_laid_off)
from layoff_stagging2
group by country
order by 2 desc;

Select year(`date`), sum(total_laid_off)
from layoff_stagging2
group by year(`date`)
order by 1;
# 2023 has the highest total_laid_off with only 3 month of data collected

#by stage
Select stage, sum(total_laid_off)
from layoff_stagging2
group by stage
order by 2 desc;

Select*
from layoff_stagging2;

#Total lay-off by month
Select substring(`date`, 1, 7) as Period , sum(total_laid_off) as Total_off
from layoff_stagging2
where substring(`date`, 1, 7) is not null
group by Period
order by Period asc; 
#Used substring on date starting at the first character to the seventh 
#Removed the null value


 #Rolling Total of Layoffs Per Month
with cte_rolling_total as 
(
Select substring(`date`, 1, 7) as Period , sum(total_laid_off) as Total_off
from layoff_stagging2
where substring(`date`, 1, 7) is not null
group by Period
order by Period asc )
select Period ,Total_off, sum(Total_off) Over(order by Period ) as Rolling_total
from  cte_rolling_total
Group by Period
;


# Number of people lay_off by the companyies in each year
Select company , year(`DATE`), sum(total_laid_off)
from layoff_stagging2
group by company, year(`DATE`)
order by 3 desc;
#Google has the highest single total_lay-off in 2023 with 12000 people



with company_year (Company, Years, total_laid_off) as
(Select company , year(`DATE`), sum(total_laid_off)
from layoff_stagging2
group by company , year(`DATE`)
order by 3 desc)
select*, dense_rank() over(partition by Years order by total_laid_off desc ) as Ranking
from company_year
where years is not null 
order by Ranking
;

#Companies with the most Layoffs per year
Select company , Year(`date`), sum(total_laid_off)
from layoff_stagging2
group by company , Year(`date`)
order by 3 desc;


with company_yearly_layoffs (Company, Years, total_laid_off) as
(Select company , Year(`date`), sum(total_laid_off)
from layoff_stagging2
group by company , Year(`date`)
order by 3 desc),  company_year_rank as
(select*, dense_rank() over(partition by Years order by total_laid_off desc ) as Ranking
from company_yearly_layoffs
where Years is not null)
select*
from company_year_rank
where Ranking <= 5
;
#The first CTE totals the layoffs, the second ranks them within each year, and the final SELECT keeps only ranks 1 to 5.








