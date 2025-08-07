# Install necessary packages required
install.packages("tidyverse")
install.packages("janitor")
install.packages("lubridate")

# Run the packages that were installed
library(tidyverse)
library(janitor)
library(lubridate)

# Read the 12 uploaded CSV files for Jan-Dec 2021
jan_2023 <- read_csv("202301-divvy-tripdata.csv")
feb_2023 <- read_csv("202302-divvy-tripdata.csv")
mar_2023 <- read_csv("202303-divvy-tripdata.csv")
apr_2023 <- read_csv("202304-divvy-tripdata.csv")
may_2023 <- read_csv("202305-divvy-tripdata.csv")
jun_2023 <- read_csv("202306-divvy-tripdata.csv")
jul_2023 <- read_csv("202307-divvy-tripdata.csv")
aug_2023 <- read_csv("202308-divvy-tripdata.csv")
sep_2023 <- read_csv("202309-divvy-tripdata.csv")
oct_2023 <- read_csv("202310-divvy-tripdata.csv")
nov_2023 <- read_csv("202311-divvy-tripdata.csv")
dec_2023 <- read_csv("202312-divvy-tripdata.csv")

# Check column headers and datatype of the 12 CSV files
glimpse(jan_2023)
glimpse(feb_2023)
glimpse(mar_2023)
glimpse(apr_2023)
glimpse(may_2023)
glimpse(jun_2023)
glimpse(jul_2023)
glimpse(aug_2023)
glimpse(sep_2023)
glimpse(oct_2023)
glimpse(nov_2023)
glimpse(dec_2023)
# Verified that all 12 files have same columns and data type, hence, good to proceed with data merging 

# ~Data Merging~
# Combine the 12 CSV data into 1 consolidated dataframe and ensure standardised column names
all_trips <- bind_rows(jan_2023, feb_2023, mar_2023, apr_2023, may_2023, jun_2023,
                       jul_2023, aug_2023, sep_2023, oct_2023, nov_2023, dec_2023) %>%
  janitor::clean_names()

# Confirm the column names and data types of merged data
glimpse(all_trips)

# Merged data has 5,719,877 rows and 13 columns

# ~Data Exploration~
# Check for rows with duplicated data
total_rows <- nrow(all_trips)
unique_rows <- nrow(distinct(all_trips))
total_duplicates <- total_rows - unique_rows
print(total_rows)
print(unique_rows)
print(total_duplicates)
# Verified that there are no duplicated rows

# Check for rows with null values
sum(!complete.cases(all_trips))
# There were 1,388,170 rows that contain at least 1 null value - need to be removed during cleaning

# Check individual columns to familiarise with data
# ride_id col - to check if there are any duplicates 
unique_ride_id <- n_distinct(all_trips$ride_id)
print(unique_ride_id)
# no duplicates hence no cleaning needed

# Check character count for ride_id
ride_id_char_counts <- all_trips %>%
  mutate(ride_id_length = nchar(ride_id)) %>%
  count(ride_id_length, sort = TRUE)
print(ride_id_char_counts)
# All ride_id have 16 characters, no cleaning required

# Check number of rideable types and their count
rideable_type_counts <- all_trips %>%
  count(rideable_type)
print(rideable_type_counts)
# There are 3 bike types - classic, bike and electric bike

# Check the data type of start_time and end_time 
started_at_class <- class(all_trips$started_at)
ended_at_class <- class(all_trips$ended_at)
print(started_at_class)
print(ended_at_class)
# Data type is "POSIXct", which is correct

# Create the new column for ride length by subtracting the start time from the end time.
all_trips <- all_trips %>%
  mutate(ride_length_sec = as.numeric(ended_at - started_at, units = "secs"))

# Check for rides that are less than 1 min - assuming these are irrelevant rides due to technical issues with bikes
# Count the number of trips with a ride length less than 60 seconds
all_trips %>%
  filter(ride_length_sec < 60) %>%
  nrow()
# There are 149,615 rows with ride lengths less than 1 min, including those with end times earlier than start times

# Check for ride length that are longer than 1 day - assuming these are irrelevant rides as users may have forgot to lock bikes or due to technical issues
# Count the number of trips with ride length more than 24 hours
all_trips %>%
  filter(ride_length_sec > (24*60*60)) %>%
  nrow()
# There are 6.418 rows with ride length longer than 1 day
# These 156,033 rows in total will be excluded during the cleaning

# Count number of rows with null values on start or end station names
sum(is.na(all_trips$start_station_name) | is.na(all_trips$end_station_name))
# 1,387,808 rows have either null values on start or end station names - to be removed during cleaning 

# Trim the start_station_name and end_station_name columns
all_trips <- all_trips %>%
  mutate(start_station_name = str_trim(start_station_name))
all_trips <- all_trips %>%
  mutate(end_station_name = str_trim(end_station_name))

# Check the total number of unique start stations
unique_start_station_name <- n_distinct(all_trips$start_station_name)
print(unique_start_station_name)
# There are 1593 unique start stations

# Check the total number of unique end stations
unique_end_station_name <- n_distinct(all_trips$end_station_name)
print(unique_end_station_name)
# There are 1598 unique end stations

# Check character count for start_station_id and end_station_id columns
start_station_id_char_counts <- all_trips %>%
  mutate(start_station_id_length = nchar(start_station_id)) %>%
  count(start_station_id_length, sort = TRUE)
print(start_station_id_char_counts)

end_station_id_char_counts <- all_trips %>%
  mutate(end_station_id_length = nchar(end_station_id)) %>%
  count(end_station_id_length, sort = TRUE)
print(end_station_id_char_counts)

# Both start_station_id and end_station_id contains varying format and character length.
# Since we can use station names to identify the stations, the station id columns do not add incremental value and will be excluded for this analysis

# Check for NA values for start_lat, start_lng, end_lat, end_lng
na_start_lat <- sum(is.na(all_trips$start_lat))
print(paste(na_start_lat))

na_start_lng <- sum(is.na(all_trips$start_lng))
print(paste(na_start_lng))

na_end_lat <- sum(is.na(all_trips$end_lat))
print(paste(na_end_lat))

na_end_lng <- sum(is.na(all_trips$end_lng))
print(paste(na_end_lng))

# There are 6990 NA values for both end_lat and eng_lng, to be removed during cleaning

# Check for invalid coordinates for start_lat, start_lng, end_lat, end_lng
invalid_start_lat <- all_trips %>%
  filter(start_lat < -90 | start_lat > 90) %>%
  nrow()
print(invalid_start_lat)

invalid_start_lng <- all_trips %>%
  filter(start_lng < -180 | start_lng > 180) %>%
  nrow()
print(invalid_start_lng)

invalid_end_lat <- all_trips %>%
  filter(end_lat < -90 | end_lat > 90) %>%
  nrow()
print(invalid_end_lat)

invalid_end_lng <- all_trips %>%
  filter(end_lng < -180 | end_lng > 180) %>%
  nrow()
print(invalid_end_lng)

# There are no invalid coordinates

# Check for empty/0 coordinates
blank_start_lat <- all_trips %>%
  filter(start_lat == 0 | start_lat == 0) %>%
  nrow()
print(blank_start_lat)

blank_start_lng <- all_trips %>%
  filter(start_lng == 0 | start_lng == 0) %>%
  nrow()
print(blank_start_lng)

blank_end_lat <- all_trips %>%
  filter(end_lat == 0 | end_lat == 0) %>%
  nrow()
print(blank_end_lat)

blank_end_lng <- all_trips %>%
  filter(end_lng == 0 | end_lng == 0) %>%
  nrow()
print(blank_end_lng)

# There are 3 end_lat and end_lng with blank coordinates - to be removed during cleaning

# Count the number of unique membership type under member_casual column
membership_type_counts <- all_trips %>%
  count(member_casual)
print(membership_type_counts)
# There are only 2 type of membership - casual and members. no cleaning required. 

# ~Data Cleaning~
all_trips_cleaned <- all_trips %>%
 drop_na() %>%
 filter(ride_length_sec <= (24*60*60)) %>%
 filter(ride_length_sec >= 60) %>%
 filter(start_station_name != "" & end_station_name != "") %>%
 filter(end_lat != 0 & end_lng != 0) %>%
 mutate(
   month = month(started_at),
          day_of_week = wday(started_at, label = TRUE),
          time_of_day = hour(started_at),
          month = factor(month.abb[month], levels = month.abb)
  ) %>%
  select(-start_station_id, -end_station_id)

# Check the details of the cleaned data
glimpse(all_trips_cleaned)
dim(all_trips_cleaned)
# Cleaned data has 4,244,054 rows and 15 columns, we are good to proceed to analysis

# ~Data Analysis~
# Count the number of rides by membership
ride_count_by_membership <- all_trips_cleaned %>%
  group_by(member_casual) %>%
  summarise(number_of_rides = n())
print(ride_count_by_membership)
# Casual: 1505189
# Member: 2738867

# Create pie chart of ride count by membership
# Firstl, we create a dataframe for membership
overall_ride_count <- data.frame(
  group=c("Casual","Members"),
  values=c(1505189,2738867)
)
head(overall_ride_count)

# Next, we calculate the percentage of each proportion
overall_ride_count_pie_data <- overall_ride_count %>%
  mutate(
    percentage = values / sum(values),
    label_y_pos = cumsum(percentage) - (0.5 * percentage)
  )

# Then, we plot a pie chart for the overall ride count by membership
overall_ride_count_pie <- ggplot(overall_ride_count_pie_data, aes(x="", y=values, fill=group))+
  geom_bar(width=1, stat="identity")+
  coord_polar("y",start=0)+
  geom_text(aes(label = scales::percent(percentage, accuracy=1)),
            position = position_stack(vjust = 0.5),
            color = "black", size=4) +
  labs(
    title = "Overall Ride Count by Membership",
    fill = "Membership Type"
  )+
  theme_void()
print(overall_ride_count_pie)
ggsave("overall_ride_count_pie.jpg", plot = overall_ride_count_pie, width = 8, height = 6, dpi = 300)
  
# Calculate the average ride length (sec) by membership
avg_ride_length_membership <- all_trips_cleaned %>%
  group_by(member_casual) %>%
  summarise(average_ride_length_min = mean(ride_length_sec/60))
# Casual: 23.2min
# Member: 12.4min

# Create bar graph of average ride length by membership
overall_avg_ride_length <- avg_ride_length_membership %>%
  ggplot(aes( x= member_casual, y = average_ride_length_min, fill = member_casual)) + 
  geom_bar(stat="identity") +
  geom_text(aes(label = round(average_ride_length_min, 1)), vjust = -0.5) +
  scale_y_continuous(labels = comma) + 
  labs(
    title = "Average Ride Length by Membership Type",
    x = "Membership Type",
    y = "Average Ride Length (Minutes)",
    fill = "Membership Type" 
  ) +
  theme_minimal()
print(overall_avg_ride_length)
ggsave("overall_avg_ride_length.jpg", plot = overall_avg_ride_length, width = 8, height = 6, dpi = 300)

# Count the number of rides by membership and ride type
ride_count_by_ridetype_membership <- all_trips_cleaned %>%
  group_by(member_casual, rideable_type) %>%
  summarise(number_of_rides = n())
print(ride_count_by_ridetype_membership)
# Only casuals are using docked_bike while members stick with only classic and electric bikes

# Create chart to show the proportion
# For casuals, first, we create a dataframe for the casuals' rideable types
casual_rideable_type <- data.frame(
  group=c("classic", "docked", "electric"),
  values=c(860634, 75376, 569179)
)
head(casual_rideable_type)

# Next, we will calculate the percentages for labels
casual_rideable_pie_data <- casual_rideable_type %>%
  mutate(
    percentage = values / sum(values),
    label_y_pos = cumsum(percentage) - (0.5 * percentage)
  )

# Lastly, plot a pie chart for casuals rideable type
casual_rideable_pie <- ggplot(casual_rideable_pie_data, aes(x="", y=values, fill=group))+
  geom_bar(width = 1, stat="identity") + 
  coord_polar("y", start=0) +
  geom_text(aes(label = scales::percent(percentage, accuracy = 1)), 
            position = position_stack(vjust = 0.5),
            color = "black", size = 4) +
  labs(
    title = "Casuals: Rideable Type Distribution",
    fill = "Bike Type"
  )+
  scale_fill_manual(values = c("classic" = "lightblue", "docked" = "pink", "electric" = "yellow")) +
  theme_void()
print(casual_rideable_pie)
ggsave("casual_rideable_pie.jpg", plot=casual_rideable_pie, width=8, height = 6, dpi = 300)

# Repeating the same steps for Members 
# First, we create a dataframe for the members' rideable types
member_rideable_type <- data.frame(
  group=c("classic", "electric"),
  values=c(1788751, 950116)
)
head(member_rideable_type)

# Next, we will calculate the percentages for labels
member_rideable_pie_data <- member_rideable_type %>%
  mutate(
    percentage = values / sum(values),
    label_y_pos = cumsum(percentage) - (0.5 * percentage)
)

# Lastly, plot a pie chart for members rideable type
member_rideable_pie <- ggplot(member_rideable_pie_data, aes(x="", y=values, fill=group))+
  geom_bar(width=1, stat="identity") +
  coord_polar("y", start=0) +
  geom_text(aes(label = scales::percent(percentage, accuracy=1)),
            position = position_stack(vjust=0.5),
            color="black", size=4) +
  labs(
    title="Members: Rideable Type Distribution",
    fill="Bike Type"
  )+
  scale_fill_manual(values = c("classic" = "lightblue", "electric" = "yellow")) +
  theme_void()
print(member_rideable_pie)
ggsave("member_rideable_pie.jpg", plot=member_rideable_pie, width=8, height=6, dpi=300)

# Count the monthly number of rides by membership 
monthly_ride_count_membership <- all_trips_cleaned %>%
  group_by(member_casual, month) %>%
  summarise(number_of_rides = n(), .groups='drop')
print(monthly_ride_count_membership)

# Plot a line graph for monthly number of rides by membership
monthly_ride_count_plot <- monthly_ride_count_membership %>%
  ggplot(aes( x= month, y = number_of_rides, color = member_casual, group = member_casual)) + 
  geom_line(size=1.2) +
  geom_point(size=2) +
  scale_y_continuous(labels = comma) + 
  labs(
    title = "Monthly Ride Count by Membership",
    x = "Month",
    y = "Number of Rides",
    color = "Membership Type" 
  ) +
  theme_minimal()
print(monthly_ride_count_plot)
ggsave("monthly_ride_count_plot.jpg", plot=monthly_ride_count_plot, width=8, height=6, dpi=300)

# Count the monthly average ride length by membership 
monthly_avg_ridelength_membership <- all_trips_cleaned %>%
  group_by(member_casual, month) %>%
  summarise(average_ride_length_min = mean(ride_length_sec)/60, .groups='drop')
print(monthly_avg_ridelength_membership)

# Plot a line graph for monthly average ride length by membership
monthly_avg_ridelength_plot <- monthly_avg_ridelength_membership %>%
  ggplot(aes( x= month, y = average_ride_length_min, color = member_casual, group = member_casual)) + 
  geom_line(size=1.2) +
  geom_point(size=2) +
  scale_y_continuous(labels = comma) + 
  labs(
    title = "Monthly Average Ride Length by Membership",
    x = "Month",
    y = "Average Ride Length (Minute)",
    color = "Membership Type" 
  ) +
  theme_minimal()
print(monthly_avg_ridelength_plot)
ggsave("monthly_avg_ridelength_plot.jpg", plot=monthly_avg_ridelength_plot, width=8, height=6, dpi=300)

# Count the day of week number of rides by membership 
weekly_ride_count_membership <- all_trips_cleaned %>%
  group_by(member_casual, day_of_week) %>%
  summarise(number_of_rides = n(), .groups='drop')
print(weekly_ride_count_membership)

# Plot a line graph for day of week number of rides by membership
weekly_ride_count_plot <- weekly_ride_count_membership %>%
  ggplot(aes( x= day_of_week, y = number_of_rides, color = member_casual, group = member_casual)) + 
  geom_line(size=1.2) +
  geom_point(size=2) +
  scale_y_continuous(labels = comma) + 
  labs(
    title = "Day of Week Ride Count by Membership",
    x = "Day",
    y = "Number of Rides",
    color = "Membership Type" 
  ) +
  theme_minimal()
print(weekly_ride_count_plot)
ggsave("weekly_ride_count_plot.jpg", plot=weekly_ride_count_plot, width=8, height=6, dpi=300)

# Count the day of week average ride length by membership 
weekly_avg_ridelength_membership <- all_trips_cleaned %>%
  group_by(member_casual, day_of_week) %>%
  summarise(average_ride_length_min = mean(ride_length_sec)/60, .groups='drop')
print(weekly_avg_ridelength_membership)

# Plot a line graph for day of week average ride length by membership 
weekly_avg_ridelength_plot <- weekly_avg_ridelength_membership %>%
  ggplot(aes( x= day_of_week, y = average_ride_length_min, color = member_casual, group = member_casual)) + 
  geom_line(size=1.2) +
  geom_point(size=2) +
  scale_y_continuous(labels = comma) + 
  labs(
    title = "weekly Average Ride Length by Membership",
    x = "Day of Week",
    y = "Average Ride Length (Minute)",
    color = "Membership Type" 
  ) +
  theme_minimal()
print(weekly_avg_ridelength_plot)
ggsave("weekly_avg_ridelength_plot.jpg", plot=weekly_avg_ridelength_plot, width=8, height=6, dpi=300)

# Count the time of day number of rides by membership 
hourly_ride_count_membership <- all_trips_cleaned %>%
  group_by(member_casual, time_of_day) %>%
  summarise(number_of_rides = n(), .groups='drop')
print(hourly_ride_count_membership)

# Plot a line graph for time of day number of rides by membership 
hourly_ride_count_plot <- hourly_ride_count_membership %>%
  ggplot(aes( x= time_of_day, y = number_of_rides, color = member_casual, group = member_casual)) + 
  geom_line(size=1.2) +
  geom_point(size=2) +
  scale_y_continuous(labels = comma) + 
  scale_x_continuous(breaks = seq(0, 23, by = 1)) +
  labs(
    title = "Time of Day Ride Count by Membership",
    x = "Time of Day",
    y = "Number of Rides",
    color = "Membership Type" 
  ) +
  theme_minimal()
print(hourly_ride_count_plot)
ggsave("hourly_ride_count_plot.jpg", plot=hourly_ride_count_plot, width=8, height=6, dpi=300)

# Count the time of day average ride length by membership 
hourly_avg_ridelength_membership <- all_trips_cleaned %>%
  group_by(member_casual, time_of_day) %>%
  summarise(average_ride_length_min = mean(ride_length_sec)/60, .groups='drop')
print(hourly_avg_ridelength_membership)

# Plot a line graph for time of day average ride length by membership 
hourly_avg_ridelength_plot <- hourly_avg_ridelength_membership %>%
  ggplot(aes( x= time_of_day, y = average_ride_length_min, color = member_casual, group = member_casual)) + 
  geom_line(size=1.2) +
  geom_point(size=2) +
  scale_y_continuous(labels = comma) + 
  scale_x_continuous(breaks = seq(0, 23, by = 1)) +
  labs(
    title = "hourly Average Ride Length by Membership",
    x = "Time of Day",
    y = "Average Ride Length (Minute)",
    color = "Membership Type" 
  ) +
  theme_minimal()
print(hourly_avg_ridelength_plot)
ggsave("hourly_avg_ridelength_plot.jpg", plot=hourly_avg_ridelength_plot, width=8, height=6, dpi=300)

# Calculate the average start location coordinates by membership 
avg_start_location_membership <- all_trips_cleaned %>%
  group_by(member_casual, start_station_name) %>%
  summarise(
    average_start_lng = mean(start_lng),
    average_start_lat = mean(start_lat),
    number_of_rides = n(), 
    .groups = 'drop'
  ) %>%
  arrange(desc(number_of_rides))
print(avg_start_location_membership)
write_csv(avg_start_location_membership, "avg_start_location_membership.csv")

# Calculate the average end location coordinates by membership 
avg_end_location_membership <- all_trips_cleaned %>%
  group_by(member_casual, end_station_name) %>%
  summarise(
    average_end_lat = mean(end_lat),
    average_end_lng = mean(end_lng),
    number_of_rides = n(), 
    .groups = 'drop'
  ) %>%
  arrange(desc(number_of_rides))
print(avg_end_location_membership)
write_csv(avg_end_location_membership, "avg_end_location_membership.csv")

# Calculate the average start location coordinates for docked bikes
avg_start_location_docked <- all_trips_cleaned %>%
  filter(
    rideable_type == "docked_bike"
  ) %>%
  group_by(start_station_name) %>%
  summarise(
    average_start_lng = mean(start_lng),
    average_start_lat = mean(start_lat),
    number_of_rides = n(), 
    .groups = 'drop'
  ) %>%
  arrange(desc(number_of_rides))
print(avg_start_location_docked)
write_csv(avg_start_location_docked, "avg_start_location_docked.csv")

# Calculate the average end location coordinates for docked bikes
avg_end_location_docked <- all_trips_cleaned %>%
  filter(
    rideable_type == "docked_bike"
  ) %>%
  group_by(member_casual, end_station_name) %>%
  summarise(
    average_end_lat = mean(end_lat),
    average_end_lng = mean(end_lng),
    number_of_rides = n(), 
    .groups = 'drop'
  ) %>%
  arrange(desc(number_of_rides))
print(avg_end_location_docked)
write_csv(avg_end_location_docked, "avg_end_location_docked.csv")
