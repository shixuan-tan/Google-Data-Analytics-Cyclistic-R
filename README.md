# Google Data Analytics Capstone Project: Cyclistic using R

# Introduction
This repository contains my capstone project for the [Google Data Analytics Professional Certificate](https://www.coursera.org/professional-certificates/google-data-analytics). 
I have applied the data analysis process (Ask, Prepare, Process, Analyze, Share and Act) to address a business question for a bike-share company, Cyclistic. By leveraging R for data cleaning, analysis and visualization, along with Tableau to visualize the top stations' coordinates, I will provide data-driven insights and actionable recommendations.

Note: I previously completed this same case study using SQL for data cleaning and analysis, and Excel and Tableau for visualization. You can view that version of the case study [here](https://github.com/shixuan-tan/Google-Data-Analytics-Cyclistic-SQL). The two projects use different years of data (2024 for SQL, 2023 for R) to intentionally analyze separate datasets for broader practice.
  
# Background
For the case study, I'm taking up the role of a Junior Data Analyst under the marketing analyst team at Cyclistic, a bike-share company in Chicago. Cyclistic has more than 5,800 bikes and 600 docking stations in Chicago. Bikes can be unlocked from one station and returned to any other station in the system anytime. Currently, they have 2 membership types, namely Members and Casual users. Casuals are defined as users who purchase single-ride or full-day passes, while Members are users who purchase annual memberships.

# Ask
Based on the findings by the finance analysts at Cyclistic, they have concluded that members are more profitable than casual riders. The director of the marketing team, Moreno, believes that we should maximize annual members by converting casual riders. To support this effort, she has assigned the team to look into how annual members and casual riders differ, why casual riders would buy a membership and how digital media could affect their marketing tactics. I have been assigned to answer the question: “How do annual members and casual riders use Cyclistic bikes differently?”

# Prepare
## Data source
I will be using Cyclistic's trip data collected in 2023 for this analysis and identify if there are any trends and patterns between Members and Casual users. The data used were downloaded from the source provided [here](https://divvy-tripdata.s3.amazonaws.com/index.html), and have been made available by Motivate International Inc. under this [license](https://divvybikes.com/data-license-agreement).

Due to data privacy protocols, personally identifiable information (PII) is not available in the dataset. This constraint prevents us from determining if casual riders are repeat users who have purchased multiple single passes. As a result, our analysis will be based solely on observed anonymized ride patterns to understand rider behavior.

## Data Organisation
I've downloaded the 12 monthly data files for the months of Jan to Dec 2023, with the naming convention of `YYYYMM-divvy-tripdata`. Each file contains ride information recorded in that month, which consists of columns `ride_id`, `bike type`, `started_at`, `ended_at`, `start_station_name`, `end_station_name`, `start_station_id`, `end_station_id` and `start_lat`, `start_lng`, `end_lat`, `end_lng` and `member_casual`.

# Process
For this analysis, I chose to work within the RStudio Desktop environment. Given the large scale of the dataset(5,719,877 rows), the cloud version of R was unable to handle the memory and processing demands. This robust desktop environment was necessary to efficiently combine, clean and analyze the data, as the volume exceeded the practical limitations of other tools like Microsoft Excel.

R scripts for Data Merging, Exploration, Cleaning and Analysis can be found in the link [here](https://github.com/shixuan-tan/Google-Data-Analytics-Cyclistic-R/blob/main/Data%20Cleaning%20&%20Analysis.R).  

After uploading the 12 files into R and confirming that the column names and data type were consistent across files, I merged them into a single data frame called “all-trips”. This table contains 5,719,877 rows for the entire year of 2023.

## Data-exploration
There are a total of 13 columns in the tables, with `ride_id` being the primary key:
<img width="740" height="318" alt="merged data" src="https://github.com/user-attachments/assets/6248d651-a129-4298-bfee-0c5905b9c0c8" />


I began by conducting a preliminary data exploration on each column of the combined table to identify key cleaning requirements. The full pre-cleaning process, documented in R scripts [here](https://github.com/shixuan-tan/Google-Data-Analytics-Cyclistic-R/blob/main/Data%20Cleaning%20&%20Analysis.R). 
Below is an example of the analysis of the `ride_id` column:

R script used to check for the number of characters in `ride_id` column.

<img width="666" height="115" alt="rideid_character_check" src="https://github.com/user-attachments/assets/9117c1c1-524b-470e-ae15-2317c55513ea" />



The output from the above script shows that all rows have unique ride IDs. 

<img width="300" height="70" alt="rideid_character_check_result" src="https://github.com/user-attachments/assets/9b4f87a7-213a-47a9-9983-1b0bec8831a8" />


### Key summary of observations:
* `ride_ID`: There were no nulls or duplicates, and all ride IDs were exactly 16 characters in length. As a result, no cleaning was required for this field.
* `rideable_type`: The data contains 3 primary `rideable_types`: electric bikes, docked bikes and classic bikes. No cleaning was required for this column.
<img width="466" height="122" alt="rideable_results" src="https://github.com/user-attachments/assets/1fec1dee-c021-414d-94cd-15f739b89b29" />

* `started_at`, `ended_at`: The columns provided trip start and end timestamps in `YYYY-MM-DD hh:mm:ss UTC` format. A new `ride_length_sec` column has been added to determine the total trip duration in seconds. 6.418 trips were longer than one day and 149,615 trips have trip durations less than one minute or with end time earlier than start time - a total of 156,033 rows have been removed during the cleaning process.
* `start_station_name`, `end_station_name`: There are 1,593 unique start stations and 1,598 unique end stations. A total of 1,387,808 rows containing missing values for either start or end station names were removed. In addition, leading and trailing spaces were also removed to ensure data consistency for the analysis.
* `start_station_id`, `end_station_id`: The columns show inconsistent character lengths and varying formats. As the corresponding `start_station_name` and `end_station_name` columns were sufficient to identify the station locations, the station ID columns were deemed as non-essential and excluded from this analysis.
* `start_lat`, `start_lng`, `end_lat`, `end_lng`: These columns show the starting and ending geographical coordinates of the bike trips, and will be used to plot on a map in Tableau during the analysis. There are 6,990 rows with NA and 3 rows with 0 coordinates in either `end_lat` or `end_lng` columns - these rows have been removed during cleaning. 
* `casual_member`: There are two distinct membership types: member and casual. No cleaning was required for this column.
<img width="466" height="122" alt="member_casual_results" src="https://github.com/user-attachments/assets/b8e6278d-8cae-4b0b-b5e9-85b99817b8b7" />



## Data Cleaning Process
In summary, I performed the following data cleaning steps:

* Cleaned station names by trimming leading and trailing spaces from `start_station_name` and `end_station_name` to standardize data entries
* Removed rows with missing values in all columns
* Removed rows with NA or 0 values in `end_lat` and `end_lng` columns
* Removed columns for `start_station_id` and `end_station_id` as the data is inconsistent and irrelevant for this analysis
* Filtered out rides shorter than one minute, longer than one day or with end time earlier than start time to ensure only valid rides were included
* Added `ride_length_seconds`,`day_of_week`, `month` and `hour_of_day` columns to facilitate deeper analysis of usage patterns

A total of 1,475,823 rows were removed during the cleaning process, resulting in a cleaned dataset with 4,244,054 rows and 15 columns.

# Analyze/Share
To investigate the differences in how annual members and casual riders use Cyclistic bikes, I leveraged R for a robust analysis of their distinct usage patterns. I have also used R's visualization capabilities to create charts and graphs, coupled with Tableau to visualize the start and end station coordinates. The R scripts for this process can be viewed [here]((https://github.com/shixuan-tan/Google-Data-Analytics-Cyclistic-R/blob/main/Data%20Cleaning%20&%20Analysis.R). 

Firstly, I examined the overall proportion of rides taken by each of the two membership types throughout 2023. This initial look at the data provided a foundational understanding of the user base before diving into more specific behavioral patterns.
<img width="460" height="303" alt="overall_ride_count_pie" src="https://github.com/user-attachments/assets/08b589b9-5873-4e97-9995-dae837b05e73" />


Members comprised the majority at 65% of the rides, with casual riders accounting for the remaining 35%.

In a similar analysis, I also looked at the overall average ride durations.

<img width="460" height="280" alt="Average Ride Length by Membership Type" src="https://github.com/user-attachments/assets/1d0b6f22-d0ea-43f7-a1aa-e4ea486fb7a6" />

Casual riders tend to take much longer trips, averaging 23.2 minutes, while members ride for a shorter average duration of 12.4 minutes, which is approximately half that of casual riders.

Next, I compared the distribution of bike types across the 3 categories: classic, electric and docked bikes. 
<img width="655" height="313" alt="rideable-pie-membership" src="https://github.com/user-attachments/assets/af7478ca-9ca3-409a-b439-3c6d09d33fa7" />


A key insight is that docked bikes were exclusively used by casual riders. When looking at preferences, members showed a clear split, with 65% opting for classic bikes and 35% for electric bikes. Casual riders, in contrast, used classic bikes for 57% of their trips, electric bikes for 38%, and docked bikes for the remaining 5%.

Subsequently, I examined the monthly data to find trends in both ride count and average ride length.
<img width="500" height="350" alt="monthly_ride_count_plot" src="https://github.com/user-attachments/assets/bc03014e-da03-450c-90e9-5fee18043f3f" />


**Ride Count:** Both annual and casual riders exhibit strong seasonal usage, with ride counts peaking in the late spring to summer months and declining in the colder months. Casual rides are highest from May to September, while members maintain high usage from May through October before tapering off.

<img width="500" height="350" alt="monthly_avg_ridelength_plot" src="https://github.com/user-attachments/assets/125b2dec-2dee-4835-a2c2-cd50ce152708" />


**Ride Length:** Casual riders show a pattern of short ride lengths in the winter months (Jan-Mar and Nov-Dec), followed by a significant increase from March to April before a steady decline after September. The peak average ride length for Casual is in July, at 25.6 minutes. In contrast, members follow a similar seasonal trend of longer rides from April to September, but with a much less significant fluctuation. Their peak average ride length was in July and August at 13.5-13.6 minutes.

Following this, I examined trends in both ride count and average ride length based on the day of the week.
<img width="500" height="350" alt="weekly_ride_count_plot" src="https://github.com/user-attachments/assets/e7f76e2f-66aa-4007-a617-0e8fa7e681ae" />


**Ride Count:** Members’ usage is consistently high during weekdays, with peaks on Tuesday through Thursday, and is at its lowest on weekends. This pattern strongly suggests routine commuting. In contrast, casual ridership rises sharply on weekends, with a clear peak on Saturday, indicating their primary use is for leisure activities.

<img width="500" height="350" alt="weekly_avg_ridelength_plot" src="https://github.com/user-attachments/assets/0545669b-647f-45a7-b1a9-3f4767f4ce1f" />

**Ride Length:** While both members and casual riders experience longer ride durations on weekends compared to weekdays, this increase is notably more pronounced for casual riders. Members, in contrast, maintain a more consistent and slightly longer average ride length on weekends.

Next, I analyzed the hourly usage patterns for both ride count and average ride length to gain a more granular perspective on user behavior.
<img width="500" height="350" alt="hourly_ride_count_plot" src="https://github.com/user-attachments/assets/51511df1-20a6-4df2-adff-5430b9a3b8a3" />


**Ride Count:** Members exhibit distinct commuting spikes in the morning (7:00-9:00 AM) and evenings (4:00-6:00 PM), with usage dropping significantly midday. This pattern strongly suggests a routine commuting schedule. In contrast, the casual ride count increases gradually throughout the day, peaking between 4:00 and 6:00 PM, which further confirms a leisure-heavy usage pattern.

<img width="500" height="350" alt="hourly_avg_ridelength_plot" src="https://github.com/user-attachments/assets/5fb3bdb4-1106-4b0e-a018-55d8fa504e29" />

**Ride Length:** The average ride length for members remains relatively consistent, with slight fluctuations around 12.5 minutes. A notable exception is a dip to around 10 minutes at 5:00 AM, which then gradually increases back to the 12.5-minute range. For casual riders, the average ride length differs greatly, with the highest ride leng

Based on these findings, we can conlude that casual riders are more likely to take trips that are approximately twice as long but less frequent, as compared to members. These extended rides predominantly occur on weekends, during midday hours, and throughout the spring and summer seasons, which points to a usage pattern largely centered around leisure and recreation. 

The usage pattern of docked bikes appears to align with the behavioral differences between casual riders and members. Casual users, often riding for recreational purposes, may travel to a park or tourist area by car or public transport, then use docked bikes to explore the area and return to the same location, making docked bikes a convenient option. In contrast, members typically use bikes for daily commutes or routine point-to-point travel, which makes dockless bikes more practical for their needs, resulting in no docked bike usage among this group.

To further understand the distinct preferences between members and casual riders, I will now analyze the locations of their most frequently used starting and ending stations to identify key areas of concentrated activity for each membership type.
<img width="671" height="537" alt="Top 10 Start Stations" src="https://github.com/user-attachments/assets/6cf6077a-8b56-4cc1-9233-9d0516062037" />

A closer look at station locations reveals a clear geographical split in usage patterns. Members are more likely to start their trips at stations located near downtown, universities, and residential areas, suggesting a usage pattern centered on daily commutes. In contrast, casual riders predominantly begin their journeys at stations near major leisure and tourist spots, including parks, harbor and aquarium.

<img width="671" height="537" alt="Top 10 End Stations" src="https://github.com/user-attachments/assets/91884bfe-78f2-4b20-8c96-048092cdeb1e" />

This trend is consistent for end stations as well. Casual riders tend to complete their trips near parks and recreational areas, while members typically end their journeys close to downtown and residential zones.

This further confirms that casual riders primarily use bikes for leisure activities while members rely on them for their daily commutes.

## Summary of findings:

| Feature                   | Members                                                                                                                                                                                                                                | Casual riders                                                                                                                                                                                                                              |
| :------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Total Ride Count          | Account for 65% of all rides, indicating a volume approximately twice that of casual riders.                                                                                                                                         | Account for 35% of all rides, constituting approximately one-third of overall ridership.                                                                                                                                                 |
| Average Ride Length       | Shorter trips (avg. 12.4 min)                                                                                                                                                                                         | Longer trips (avg. 23.2 min)                                                                                                                                                             |
| Bike Trips       | Predominantly classic and electric bikes                                                                                                                                         | A mix of classic, electric, and exclusively docked bikes                                                                                                                                       |
| Purpose of bike usage     | Primarily use bikes for daily commutes on weekdays, with heavier usage during commute hours in the morning (7-9AM) and evenings (4-6PM). Consistent high usage from spring through fall.                                                                    | Mostly leisure-orientated, predominantly during mid-days on weekends, and highly seasonal (spring-summer) with significant drop in winter.                                                                                                            |
| Preferred Locations       | Stations near residential areas and the downtown.                                                                                                                                         | Stations near recreational sites such as parks, harbor, lakes and aquarium.                                                                                                                                         |

# Act
Based on these differentiating usage patterns, I recommend the following marketing and operational strategies to Moreno and her team, aimed at increasing annual memberships:

1. Introduce Weekend-only Membership Plan
* Create a new membership plan targeted towards weekend leisure users during the peak spring-summer months.
* This pass offer a low-commitment option that appeals to weekend recreational riders and encourages them to convert into members. 

2. Develop Targeted Digital Marketing Campaign
* Run digital campaigns that emphasizes the cost savings of a weekend-only membership plan to encourage conversion
* These ads can be delivered to casual riders using first-party custom audience targeting, or through geo-targeting to reach those in popular leisure spots during weekends.

3. Launch Targeted Weekend On-site Promotions
* Organise marketing booths near top stations frequently used by casual riders on weekends of peak season.
* Staff can promote the new weekend-only membership plan and offer on-the-spot signup incentives to drive conversions.

4. Optimise Bike Rebalancing for Weekend Leisure Demand
* Implement a dynamic bike rebalancing program that anticipates and meets the weekend surge in casual ridership around leisure areas.
* Cyclistic can reallocate bikes from downtown/commuter areas to key leisure attractions on Friday evenings, and then shifting them back on Sunday nights.
* This ensures bike availability when and where casual riders need them, enhancing user experience and making membership more appealing.
