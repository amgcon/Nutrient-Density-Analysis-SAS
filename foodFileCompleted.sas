/*1. Define the object: problem statement. What am I trying to solve? */
/*Questions are listed to create a list of helpful foods for specific health goals. */

/*2. Collecting the data: dataset for foods with nutrient density */
/*DATA FROM: United States Department of Agriculture’s Food Composition Database, recommended serving size*/

/*3. Scrub the data: remove major errors, duplicates, outliers, remove unwanted data points
bringing in structure to data, filling in major gaps */

/*4. Analyze the data: univariate/bivariate, time-series, regression
how to apply: descriptive analysis - what has already happened, diagnostic analysis - why
something has already happened, predictive analysis - to identify fiture trends, prescriptive analysis */

/*5. Share the insights - interpreting outcomes, and presenting them in digestible manner (reports, dashboards) */

/*Excel file is easier to import than CSV - so Excel was used to clean up columns before import */



/******************************** DATA MANIPULATION **********************/
/*************************************************************************/

/* Create file and backup file */
Data Amir.foodFile;
set Amir.foodSimp;
run;

Data Amir.foodFilebk;
set Amir.foodFile;
run;

/* Clean the dataset / properly label - though it is already clean */
/*Labels for columns */
Data Amir.foodFile;
set Amir.foodFile;
label 	Category = 'General Category'
		Description = 'Description or Food preparation'
		DataBNum = 'Nutrient Data Bank Number'
		AlphaCar = 'Alpha Carotene mcg'
		BetaCaro = 'Beta Carotene mcg'
		BCryptoxanthin = 'Beta Cryptoxanthin mcg'
		Carbs = 'Carbohydrates g'
		Cholesterol = 'Cholesterol mg'
		Choline = 'Choline mg'
		Fiber = 'Fiber g'
		LuteinZeaxanthin = 'Lutein and Zeaxanthin mcg'
		Lycopene = 'Lycopene'
		Niacin = 'Niacin mg'
		Protein = 'Protein g'
		Retinol = 'Retinol mcg'
		Riboflavin = 'Riboflavin mg'
		Selenium = 'Selenium mcg'
		SugarTot = 'Sugar total g'
		Thiamin = 'Thiamin mg'
		Water = 'Water g'
		MonosatFat = 'Monosaturated fat g'
		PolysatFat = 'Poly saturated fat g'
		SatFat = 'Saturated fat g'
		TotLipid = 'Total lipid g'
		Calcium = 'Calcium mg'
		Copper = 'Copper mg'
		Iron = 'Iron mg'
		Magnesium = 'Magnesium mg'
		Phosphorus = 'Phosphorus mg'
		Potassium = 'Potassium mg'
		Sodium = 'Sodium mg'
		Zinc = 'Zinc mg'
		A = 'Vitamin A mcg'
		B12 = 'Vitamin B12 mcg'
		B6 = 'Vitamin B6 mg'
		C = 'Vitamin C mg'
		E = 'Vitamin E mg'
		K = 'Vitamin K mcg';
run;


/*File doesnt have any inconsistensies so we will check for duplicates and sort file*/
/*No duplicate refs found in drfoodfile*/
proc sort data = Amir.FoodFile out=Amir.dfFoodFile dupout=Amir.drFoodFile nodup;
by DataBNum;
run;


/*What foods are the highest in carbs? */
Data Amir.hcarbs;
set Amir.foodfile;
if Carbs > 30; /*30 grams*/
keep Category Description DataBNum Carbs SugarTot Fiber;
run;

/*which method of cooking rice is lowest in carbs, and low in sugar? Sort list in desc by carbs */
Data Amir.ricelcarb;
set Amir.foodfile;
where (Category = 'Rice') and (Carbs < 30) and (SugarTot < 8);
keep Category Description DataBNum Carbs SugarTot;
run;

proc sort data = Amir.ricelcarb;
BY DESCENDING carbs;
run;

/*What foods are the highest in saturated fats? */
Data Amir.sffood;
set Amir.foodfile;
if (satFat > 5);
keep Category Description DataBNum satFat polysatfat monosatfat;
run;

/*High in satfat and is not milk, cheese by itself, or ice cream - sort desc*/
Data Amir.sffoodnd;
set Amir.foodfile;
where (satFat > 5) and (category not in('Milk', 'Buttermilk', 'Cheese', 'Cream') 
  and (Description not like '%cheese%')
  and (Description not like '%cream%')
  and (Description not like '%Ice cream%'));
keep Category Description DataBNum satFat polysatfat monosatfat;
run;

proc sort data = Amir.sffoodnd;
BY DESCENDING satfat;
run;

/*What foods are highest in protein? */
Data Amir.hpfood;
set Amir.foodfile;
where protein > 30;
keep Category Description DataBNum protein;
run;

proc sort data = Amir.hpfood;
BY DESCENDING protein;
run;

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


/*Which foods have the most b vitamins and protein content, sort by most protein? (beneficial for energy production) */
Data Amir.BPfoods;
set Amir.foodfile;
where b12 > 1.2 and niacin > 7 and thiamin > 0.3 and b6 > 0.2 and riboflavin > 0.2 and protein > 15;
keep Category Description DataBNum thiamin riboflavin niacin b12 b6 protein;
run;

proc sort data=Amir.bpfoods;
by descending protein;
run;

/*Low carb and low fat foods?*/
Data Amir.lclffood;
set Amir.foodfile;
where carbs < 10 and totalFat < 20 and (category not in ('Infant formula'));
keep Category Description DataBNum carbs totalFat;
run;

/*What are the top 100 low carb options with high fiber? */
Data Amir.lchffood;
set Amir.foodfile;
where carbs < 20 and fiber > 3;
keep Category Description DataBNum carbs fiber;
run;

/*sort by asc to put lowest at the top*/
proc sql outobs=100;
   create table Amir.lchffood100
     as select * from Amir.lchffood
     order by carbs asc;
quit;


/*Which foods are best to increase testosterone? D, Cholesterol, selenium, B vitamins, protein */
Data Amir.htfood;
set Amir.foodfile;
where b12 > 1.2 and protein > 15 and selenium > 25 and zinc > 5 and cholesterol < 100 ;
keep Category Description DataBNum Cholesterol selenium B12 Zinc protein;
run;

/*Separate macros: carbs, fats, proteins to top 200 sources of each. */
/*THEN merge all 3 tables - this will be the healthy foods table */

/*add total fat column */
Data Amir.foodfile;
set Amir.foodfile;
totalfat = polysatfat + monosatfat + satfat;
label totalfat = 'poly+mono+sat fats';
run;

/*separate the files with highest protein fat and a healthy range of carbs */
Data Amir.hcfood Amir.hpfood Amir.hffood Amir.ofood;
set Amir.foodfile;
if carbs > 30 and carbs < 60 then output Amir.hcfood; /*range of carbs for total intake*/
else if protein > 20 then output Amir.hpfood;
else if totalfat > 20 then output Amir.hffood;
else output Amir.ofood;
keep Category Description DataBNum totalfat protein carbs;
run;

/*sort each protein fat carb table from greatest to least with 200 obs*/
proc sql outobs=200;
   create table Amir.hcfood200
     as select * from Amir.hcfood
     order by carbs desc;
quit;

proc sql outobs=200;
   create table Amir.hffood200
     as select * from Amir.hffood
     order by totalfat desc;
quit;

proc sql outobs=200;
   create table Amir.hpfood200
     as select * from Amir.hpfood
     order by protein desc;
quit;

/*Merge the tables: hffood200, hpfood200, hcfood200 */
/*sort the data first */
proc sort data = Amir.hffood200;
by DataBNum;
run;

proc sort data = Amir.hpfood200;
by DataBNum;
run;

proc sort data = Amir.hcfood200;
by DataBNum;
run;

Data Amir.mergehfcp;
merge Amir.hffood200 Amir.hcfood200 Amir.hpfood200;
by DataBNum;
run;

/* What are good low carb and high protein foods? */
/*Demonstrate the process of joining */
Data Amir.lcfood;
set Amir.foodfile;
where carbs < 10;
keep Category Description DataBNum carbs;
run;

Data Amir.hpfood30;
set Amir.foodfile;
where protein > 30;
keep Category Description DataBNum protein;
run;

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
 


/*************************DATA VISULIZATION**********************/
/****************************************************************/

/*Create category macro*/
%let vcat = category;
%let top10 = 10;
%let top15 = 15;
%let top20 = 20;

/*What category of foods are the highest in carbs? */

/*check the frequency of categories*/ 
proc freq data=Amir.hcfood ORDER=FREQ noprint;
tables &vcat / out=Amir.hcfoodfreq;
run;

/*create other category*/
data Amir.hcother;
set Amir.hcfoodfreq;
label topCat = 'Top 10 High Carb Categories & Other';
topCat = &vcat;
if _n_ > &top10 then
	topCat='Other';
run;

proc freq data= Amir.hcother ORDER=data;   /* order by data and use WEIGHT statement for count */
  tables TopCat / plots=FreqPlot(scale=percent);
  weight Count;                  
run;

/* What foods are highest in protein? */
proc freq data=Amir.hpfood ORDER=FREQ noprint;
tables &vcat / out=Amir.pfoodfreq;
run;

/*create other category*/
data Amir.pother;
set Amir.pfoodfreq;
label topCatp = 'Top 20 High Protein Categories & Other';
topCatp = &vcat;
if _n_ > &top20 then
	topCatp='Other';
run;

proc freq data= Amir.pother ORDER=data;   /* order by data and use WEIGHT statement for count */
  tables topCatp / plots=FreqPlot(scale=freq);
  weight Count;                  
run;
/*proc gchart data = Amir.hcother;
vbar topcat / discrete type=sum sumvar=count levels=all (scale=percent);
run;*/

/*Category of foods highest in saturated fats? */
proc freq data=Amir.sffood ORDER=FREQ noprint;
tables &vcat / out=Amir.sffoodfreq;
run;

/*create other category*/
data Amir.hsfother;
set Amir.sffoodfreq;
label topCatsf = 'Top 20 Sat. Fat Categories & Other';
topCatsf = &vcat;
if _n_ > &top20 then
	topCatsf='Other';
run;

proc freq data= Amir.hsfother ORDER=data;   /* order by data and use WEIGHT statement for count */
  tables TopCatsf / plots=FreqPlot(scale=percent);
  weight Count;                  
run;


/*What are the top 10 low carb categories with high fiber? */
/*check the frequency of categories*/ 
proc freq data=Amir.lchffood ORDER=FREQ noprint;
tables &vcat / out=Amir.lchffoodfreq;
run;

/*create other category*/
data Amir.lchfother;
set Amir.lchffoodfreq;
label topCatlchf = 'Top 10 Low Carb/High Fiber Categories & Other';
topCatlchf = &vcat;
if _n_ > &top10 then
	topCatlchf='Other';
run;

proc freq data= Amir.lchfother ORDER=data;   /* order by data and use WEIGHT statement for count */
  tables TopCatlchf / plots=FreqPlot(scale=percent);
  weight Count;                  
run;
/*What category of foods are highest in electrolytes? */
/*Sodium*/
proc freq data=Amir.sodfood ORDER=FREQ noprint;
tables &vcat / out=Amir.sodfoodfreq;
run;

/*create other category*/
data Amir.sodother;
set Amir.sodfoodfreq;
label topCatsod = 'Top 15 Categories for Sodium';
topCatsod = &vcat;
if _n_ <= &top15; /*only the 20 categories */
/*if _n_ > &top20 then
	topCatsod='Other'; */
run;

/* pie chart for sodium */
proc gchart data = Amir.sodother;
pie topCatsod / discrete percent = inside sumvar = count explode='Bread';
run; quit;

/* Calcium */
proc freq data=Amir.calfood ORDER=FREQ noprint;
tables &vcat / out=Amir.calfoodfreq;
run;

/*create other category*/
data Amir.calother;
set Amir.calfoodfreq;
label topCatcal = 'Top 10 Categories for Calcium';
topCatcal = &vcat;
if _n_ <= &top10; /*only the 10 categories */
/*if _n_ > &top10 then
	topCatcal='Other'; */
run;

/* pie chart for calcium */
proc gchart data = Amir.calother;
pie topCatcal / discrete percent = inside sumvar = count explode='Chocolate milk';
run; quit;

/*Potassium*/
proc freq data=Amir.potfood ORDER=FREQ noprint;
tables &vcat / out=Amir.potfoodfreq;
run;

/*create other category*/
data Amir.potother;
set Amir.potfoodfreq;
label topCatpot = 'Top 10 Categories for Potassium';
topCatpot = &vcat;
if _n_ <= &top10; /*only the 10 categories */
/*if _n_ > &top10 then
	topCatpot='Other'; */
run;

/* pie chart for calcium */
proc gchart data = Amir.potother;
pie topCatpot / discrete percent = inside sumvar = count explode='Chocolate';
run; quit;

/* What are the top 100 low carb options with high fiber? */
proc freq data=Amir.lchffood ORDER=FREQ noprint;
tables &vcat / out=Amir.lchffoodfreq;
run;

/*create other category*/
data Amir.lchfother;
set Amir.lchffoodfreq;
label topCatlchf = 'Top 15 Low carb High fiber Categories & Other';
topCatlchf = &vcat;
if _n_ > &top15 then
	topCatlchf='Other';
run;

proc freq data= Amir.lchfother ORDER=data;   /* order by data and use WEIGHT statement for count */
  tables TopCatlchf / plots=FreqPlot(scale=percent);
  weight Count;                  
run;

/*What category of foods is best to increase testosterone? */

proc freq data=Amir.htfood ORDER=FREQ noprint;
tables &vcat / out=Amir.htfoodfreq;
run;

/*create other category*/
data Amir.htother;
set Amir.htfoodfreq;
label topCatht = 'Top Categories for Testosterone boosting foods';
if category = 'Steak' then category = 'Beef steak'; /*small data correction for the chart*/
topCatht = &vcat;
if _n_ <= 5; /*only the 5 categories */
/*if _n_ > &top10 then
	topCatht='Other'; */
run;

/* vertical chart for high test boosting foods */
proc gchart data = Amir.htother;
vbar topCatht / discrete inside = percent sumvar = count;
run; quit;

/*What category of protein rich foods has the most b-vitamins? */
/*check the frequency of categories*/ 
proc freq data=Amir.bpfoods ORDER=FREQ noprint;
tables &vcat / out=Amir.bpfoodfreq;
run;

/*create other category*/
data Amir.bpother;
set Amir.bpfoodfreq;
label topCatbp = 'Top 5 Protein rich B-Vitamin foods';
topCatbp = &vcat;
if _n_ > 5 then
	topCatbp='Other';
run;

/*frequency chart for bvitamin and protein rich foods*/
proc freq data= Amir.bpother ORDER=data;   /* order by data and use WEIGHT statement for count */
  tables TopCatbp / plots=FreqPlot(scale=percent);
  weight Count;                  
run;

/*What category of foods are high protein and low carbs? */
/*Can use the lchp_ij inner join table*/

/*check the frequency of categories*/ 
proc freq data=Amir.lchp_ij ORDER=FREQ noprint;
tables &vcat / out=Amir.lchpfoodfreq;
run;

/*create other category*/
data Amir.lchpother;
set Amir.lchpfoodfreq;
label topCatlchp = 'Top 10 Low carb/High protein foods';
topCatlchp = &vcat;
if _n_ > &top10 then
	topCatlchp='Other';
run;

/*frequency chart for lchp rich foods*/
proc freq data= Amir.lchpother ORDER=data;   /* order by data and use WEIGHT statement for count */
  tables TopCatlchp / plots=FreqPlot(scale=percent);
  weight Count;                  
run;

/*Low carb and low fat foods */
/*check the frequency of categories*/ 
proc freq data=Amir.lclffood ORDER=FREQ noprint;
tables &vcat / out=Amir.lclffoodfreq;
run;

/*create other category*/
data Amir.lclfother;
set Amir.lclffoodfreq;
label topCatlclf = 'Top 20 Low carb/Low Fat foods';
topCatlclf = &vcat;
if _n_ <= &top20;
run;

/*frequency chart for lchp rich foods*/
proc freq data= Amir.lclfother ORDER=data;   /* order by data and use WEIGHT statement for count */
  tables TopCatlclf / plots=FreqPlot(scale=percent);
  weight Count;                  
run;

/*Highest protein, fat and a healthy range of carbs?*/
proc freq data=Amir.mergehfcp ORDER=FREQ noprint;
tables &vcat / out=Amir.fcpfoodfreq;
run;

/*create other category*/
data Amir.fcpfother;
set Amir.fcpfoodfreq;
label topCatfcp = 'Top 20 Healthy sources of Carbs, Fats, Protein';
topCatfcp = &vcat;
if _n_ <= &top20;
run;

/*frequency chart for lchp rich foods*/
proc freq data= Amir.fcpfother ORDER=data;   /* order by data and use WEIGHT statement for count */
  tables TopCatfcp / plots=FreqPlot(scale=percent);
  weight Count;                  
run;

/****************** STATISTICAL ANALYSIS **************************/
/******************************************************************/

/*Mean Median Std Dev of the top 200 high protein, fat and healthy carbs*/
proc means data = Amir.hcfood200 order=freq mean median stddev;
var carbs;
class category;
run;

proc means data = Amir.hpfood200 order=freq mean median stddev;
var protein;
class category;
run;

proc means data = Amir.hffood200 order=freq mean median stddev;
var totalfat;
class category;
run;

/*Univariate of top 600 foods based on protein fat and carbs*/
proc univariate data=Amir.mergehfcp;
var carbs protein totalFat;
run;

/*Simple random sampling*/
proc surveyselect data = Amir.foodfile method=srs n=1000 out=Amir.foodSample;
run;

/*Paired sample test */
/*H0: There is no significant mean difference between 2 variables from 0 */
/*H1: There is a significant mean difference between 2 variables from 0 */
proc ttest data = Amir.foodsample;
paired carbs*sugartot;
run;
/*PR: <.0001 (less than 0.05)- therefore this is contributing highly and the null hypothesis is rejected */

/*Correlation between sugar and carbs*/
proc corr data=Amir.foodsample;
var carbs sugartot;
run;
/*Correlation value: 0.71841 is a strong positive correlation between sugar and carbs */

/*Correlation values for macros which correlate with electrolytes */
proc corr data=Amir.foodsample;
var protein carbs totalFat sodium potassium calcium;
run;

/*Sodium-Protein: ftest (0.41090) - weak pos correlation*/
/*Linear regression Model */
proc reg data = Amir.foodsample;
	model protein = sodium;
run; quit;
/*ftest: <.0001 - contributing highly */

/*Calcium-carbs: ftest (0.17877) - weak pos correlation*/
/*Linear regression Model */
proc reg data = Amir.foodsample;
	model carbs = calcium;
run; quit;
/*ftest: <.0001 - contributing highly */

/*Potassium-protein: ftest (0.46165) - weak pos correlation*/
/*Linear regression Model */
proc reg data = Amir.foodsample;
	model protein = potassium;
run; quit;

/*ftest: <.0001 - contributing highly */

/*ANOVA Category*/
proc Anova data = Amir.foodsample;
class category;
model magnesium=category;
run;










