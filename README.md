# ANALYSIS OF THE MOST NUTRIENT DENSE FOODS
### INTRODUCTION
This SAS coded project analyzes the most nutrient dense foods by category for specific health goals. This analysis aims to simplify the consumption of foods most dense in Macronutrients (Carbs, Fats, Protein) and high in Micronutrients. This analysis will provide insight on dietary information which allows readers to make data driven decisions to efficiently fulfill specific dietary requirements and goals. 
### PROBLEM STATEMENT
1. What foods are the highest in carbohydrates?
2. What foods are highest in protein?
3. What foods are the highest in saturated fats?
4. What foods have the best electrolyte content? (Based on Sodium, Potassium, Calcium)
5. Which foods have the most b-vitamins and protein content? (Energy production.)
6. What are the top 100 low carbohydrate options with high fiber?
7. Which foods are best to increase testosterone? (Vitamin D, Cholesterol, selenium, B vitamins, protein)
8. Highest protein, fat and a healthy range of carbs?
9. What are good low carb and low fat foods?
10. What are good low carb and high protein foods?
11. What is the correlation between carbohydrates and sugar content?
12. What are the top foods to support a healthy intake of macronutrient consumption? (i.e. Healthy carb range, sufficient fat, and high protein)
13. What is the correlation between a healthy electrolyte balance and consuming the right macronutrients?

### SKILLS / CONCEPTS DEMONSTRATED
#### **Data Manipulation / Data modelling**
- Cleaning & structuring data, freq tables, sorting data sets, separating data sets, removing outliers
#### **Data Visualization**
- Freq plots, pie charts, gcharts.
#### **Statistical analysis**
- Mean, median, standard deviations, simple random sampling, paired sample test, data correlation, regression models, anova
- Interpretation of analysis techniques
  
### THE DATA
This data was obtained from kaggle [link](https://www.kaggle.com/datasets/mexwell/food-vitamins-minerals-macronutrient) by using the United States Department of Agriculture’s Food Composition Database.

### DATA MANIPULATION
- Clean (no duplicates, outliers, inconsistent data, etc.) and label the categories
```sas
Data Amir.foodFile;
set Amir.foodFile;
label 	Category = 'General Category'
		Description = 'Description or Food preparation'
		DataBNum = 'Nutrient Data Bank Number'
		AlphaCar = 'Alpha Carotene mcg'
		BetaCaro = 'Beta Carotene mcg'
    /*and so on..*/
run;
```
- Verify data types for easy analysis (char, num)
- Sort by Nutrient Data Bank Number, ascending, or descending
```sas
  /*No duplicate refs found in drfoodfile*/
  proc sort data = Amir.FoodFile out=Amir.dfFoodFile dupout=Amir.drFoodFile nodup;
  by DataBNum;
run;
```
#### Structure data:
- Create tables based on problem statement for analysis
```sas
  /*What are the top 100 low carb options with high fiber? */
  Data Amir.lchffood;
  set Amir.foodfile;
  where carbs < 20 and fiber > 3;
  keep Category Description DataBNum carbs fiber;
  run;
```
- Minimize list to top sources of nutrients based on problem statement
```sas
/*What foods have the best electrolyte content? Calcium. Magnesium. Phosphorus. Potassium. Sodium. - but based on Sodium, Potassium, Calcium*/
/*above 10% - 230 for sod, 150 - pot,  */
Data Amir.sodFood Amir.potFood Amir.calFood Amir.oeFood;
set Amir.foodfile;
if Sodium < 1500 and Sodium > 300 then output Amir.sodFood; /*good range of sodium*/
else if Potassium > 300 and Potassium < 1500 then output Amir.potFood; /*good range of K*/
else if Calcium >  150 and Calcium < 1000 then output Amir.calFood; /*good range of calcium*/
else output Amir.oeFood;
keep Category Description DataBNum calcium magnesium potassium phosphorus sodium;
run;

/*take the top 25 of each and place in seperate files*/
proc sql outobs=25;
   create table sodfood25
     as select * from Amir.sodFood
     order by sodium desc;
quit;

proc sql outobs=25;
   create table potfood25
     as select * from Amir.potfood
     order by potassium desc;
quit;

proc sql outobs=25;
   create table calfood25
     as select * from Amir.calfood
     order by calcium desc; /*sort highest to lowest calcium value then take top 25*/
quit;
```
- Incorporate frequency tables for easy analysis of top sources
```sas
/*What category of foods are the highest in carbs? */

/*check the frequency of categories*/ 
proc freq data=Amir.hcfood ORDER=FREQ noprint;
tables &vcat / out=Amir.hcfoodfreq; /*macro category*/
run;

/*create other category for any sources not in the top 10*/
data Amir.hcother;
set Amir.hcfoodfreq;
label topCat = 'Top 10 High Carb Categories & Other';
topCat = &vcat;
if _n_ > &top10 then /*macro value of 10*/
	topCat='Other';
run;
```
- Integrate join techniques to specify nutrient densities
```sas
/*based on procedure (good practice) ensure no duplicates then join*/
proc sort data=Amir.lcfood out=Amir.dflcfood nodup;
by dataBNum;
run;

proc sort data=Amir.hpfood30 out=Amir.dfhpfood30 nodup;
by dataBNum;
run;

/*inner join high protein 30g low carb < 15g*/
proc sql;
create table Amir.lchp_ij as
select dfhpfood30.DataBNum, dfhpfood30.category, dfhpfood30.description, *
from Amir.dflcfood inner join Amir.dfhpfood30
on dflcfood.dataBNum = dfhpfood30.dataBNum; quit;

/*right join high protein 30g low carb < 15g*/
proc sql;
create table Amir.lchp_rj as
select dfhpfood30.DataBNum, dfhpfood30.category, dfhpfood30.description, *
from Amir.dflcfood right join Amir.dfhpfood30 
on dflcfood.dataBNum = dfhpfood30.dataBNum; quit;

/*left join*/
proc sql;
create table Amir.lchp_lj as
select dflcfood.DataBNum, dflcfood.category, dflcfood.description, *
from Amir.dflcfood left join Amir.dfhpfood30
on dflcfood.dataBNum = dfhpfood30.dataBNum; quit;

/*full join of low fat and high protein*/
proc sql;
create table Amir.lfhp_fj as
select coalesce (dflcfood.dataBNum, dfhpfood30.dataBNum) as DataBNum, 
		coalesce (dflcfood.description, dfhpfood30.description) as Description,
		coalesce (dflcfood.category, dfhpfood30.category) as category, *
from Amir.dflcfood full join Amir.dfhpfood30
on dflcfood.dataBNum = dfhpfood30.dataBNum; quit;
```

### VISUALIZATION
#### The main techniques used to visualize are:
1. Frequency plots / Frequency tables
```sas
	/* Low carb High fiber, top 10 sources freq table freq plot */
	proc freq data= Amir.lchfother ORDER=data;   /* order by data and use WEIGHT statement for count */
	tables TopCatlchf / plots=FreqPlot(scale=percent);
	weight Count;                  
	run;	
```
2. Gchart: vbar, hbar.
```sas
	/* vertical chart for high testosterone boosting foods */
	proc gchart data = Amir.htother;
	vbar topCatht / discrete inside = percent sumvar = count;
	run; quit;
``` 
3. Gchart: Pie 
```sas
	/* pie chart for calcium */
	proc gchart data = Amir.calother;
	pie topCatcal / discrete percent = inside sumvar = count explode='Chocolate milk';
	run; quit;
```

#### Below are the corresponding visualizations for the problem statements: 
What foods are the highest in carbohydrates?
What foods are highest in protein?
What foods are the highest in saturated fats?
What foods have the best electrolyte content? (Based on Sodium, Potassium, Calcium)
Which foods have the most b-vitamins and protein content? (Energy production.)
What are the top 100 low carbohydrate options with high fiber?
Which foods are best to increase testosterone? (Vitamin D, Cholesterol, selenium, B vitamins, protein)
Highest protein, fat and a healthy range of carbs?
What are good low carb and low fat foods?
What are good low carb and high protein foods?
