# Load dataset
airbnb <- read.csv("Airbnb_Open_Data.csv")
summary(airbnb)
head(airbnb)

# Description of dataset
str(airbnb)

# Clean price column by removing '$' and ',', converting into interger
airbnb$price <- gsub("\\$|\\,", "", airbnb$price)
airbnb$price <- as.integer(airbnb$price)

sum(is.na(airbnb$price))
airbnb <- na.omit(airbnb, subset = c("price"))
summary(airbnb$price)

# Clean neighbourhood.group column
airbnb$neighbourhood.group <- gsub("brookln", "Brooklyn", airbnb$neighbourhood.group) # replace brookln with Brooklyn
airbnb$neighbourhood.group <- gsub("manhatan", "Manhattan", airbnb$neighbourhood.group) # replace manhatan with Manhattan
summary(airbnb$neighbourhood.group)
unique(airbnb$neighbourhood.group)

# Remove empty strings in the neighbourhood.group column
airbnb <- airbnb[airbnb$neighbourhood.group != "", ]
unique(airbnb$neighbourhood.group)

# Clean room.type column and convert to factor
airbnb$room.type <- as.factor(airbnb$room.type) 
summary(airbnb$room.type)

# Load library
library(ggplot2)
library(tidyverse)

# Select columns
vars <- c("price", "minimum.nights", "number.of.reviews", "availability.365")
airbnb_subset <- airbnb %>% select(all_of(vars))

# Remove negative values
airbnb_subset <- airbnb_subset %>% 
  filter(minimum.nights >= 0) %>%
  filter(number.of.reviews >= 0) %>%
  filter(availability.365 >= 0)

# Fill missing values with median
airbnb_subset$minimum.nights[is.na(airbnb_subset$minimum.nights)] <- median(airbnb_subset$minimum.nights, na.rm = TRUE)
airbnb_subset$number.of.reviews[is.na(airbnb_subset$number.of.reviews)] <- median(airbnb_subset$number.of_reviews, na.rm = TRUE)
airbnb_subset$availability.365[is.na(airbnb_subset$availability.365)] <- median(airbnb_subset$availability.365, na.rm = TRUE)

# Remove outliers
airbnb_subset <- airbnb_subset %>%
  filter(minimum.nights <= quantile(minimum.nights, 0.99)) %>%
  filter(number.of.reviews <= quantile(number.of.reviews, 0.99)) %>%
  filter(availability.365 <= quantile(availability.365, 0.99))

pairs(airbnb_subset)

# Begin with barplots that will help us visualize the quantity
# Create a data frame with room types and their counts
table(airbnb$room.type)
room_counts <- data.frame(room_type = c("Entire home/apt", "Private room", "Shared room", "Hotel room"),
                          count = c(45075, 38348, 1688, 114))

# Sort the room types by count in descending order
room_counts$room_type <- reorder(room_counts$room_type, -room_counts$count)

# Plot the counts for each room type in descending order (w/ Airbnb hex color)
ggplot(room_counts, aes(x = room_type, y = count)) +
  geom_bar(stat = "identity", fill = "#FF5A5F") +
  xlab("Room Type") +
  ylab("Count") +
  ggtitle("Airbnb Room Type Counts (Descending Order)")

# Create a data frame with neighborhood groups and their counts
table(airbnb$neighbourhood.group)
neighborhood_counts <- data.frame(neighborhood_group = c("Brooklyn", "Manhattan", "Queens", "Staten Island", "Bronx"),
                                  count = c(35369, 35337, 11355, 839, 2325))

# Sort the data frame by count in descending order
neighborhood_counts$neighborhood_group <- reorder(neighborhood_counts$neighborhood_group, -neighborhood_counts$count)

# Define colors for each neighborhood group
colors <- c("#0072B2", "#009E73", "#D55E00", "#CC79A7", "#E69F00")

# Plot the counts for each neighborhood group
ggplot(neighborhood_counts, aes(x = neighborhood_group, y = count, fill = neighborhood_group)) +
  geom_bar(stat = "identity") +
  xlab("Neighborhood Group") +
  ylab("Count") +
  ggtitle("Airbnb Neighborhood Group Counts") +
  scale_fill_manual(values = colors)

# Calculate the median price by different borough and room type
room_median <- aggregate(price ~ neighbourhood.group + room.type, data = airbnb, FUN = median)
room_median

# Map Visualization
# Load required packages
library(leaflet)

# Aggregate data by neighbourhood group and room type to get median price
grouped_data <- airbnb %>%
  group_by(neighbourhood.group, room.type) %>%
  summarize(price = median(price, na.rm = TRUE),
            long = median(long, na.rm = TRUE),
            lat = median(lat, na.rm = TRUE),
            .groups = 'drop')

# Define colors for different price levels
colors <- c("#ffffcc", "#a1dab4", "#41b6c4", "#2c7fb8")

# Create the map using leaflet
map <- leaflet(grouped_data) %>%
  addTiles() %>%
  setView(lng = -73.97, lat = 40.75, zoom = 11) %>%
  addCircleMarkers(
    lng = ~long,
    lat = ~lat,
    fillColor = ~colorQuantile(colors, price)(price),
    fillOpacity = 0.6,
    stroke = FALSE,
    radius = 5,
    popup = ~paste("Neighborhood Group: ", neighbourhood.group, "<br>",
                   "Room Type: ", room.type, "<br>",
                   "Median Price: $", formatC(price, digits = 0, format = "d", big.mark = ",")),
    label = ~paste("Price: $", formatC(price, digits = 0, format = "d", big.mark = ",")),
    labelOptions = labelOptions(noHide = TRUE, textOnly = TRUE, direction = "auto")
  )

# Add legend to the map
map <- addLegend(
  map = map,
  position = "bottomright",
  pal = colorQuantile(colors, domain = grouped_data$price),
  values = grouped_data$price,
  title = "Median Price ($)",
  opacity = 1
)

map

# Association Analysis
# Find the relationship between price and neighbourhood.group
table(airbnb$price, airbnb$neighbourhood.group)

ggplot(airbnb, aes(x = neighbourhood.group, y = price)) +
  geom_boxplot() +
  xlab("Neighborhood Group") +
  ylab("Price") +
  ggtitle("Price Distribution by Neighborhood Group")

ggplot(airbnb, aes(x = room.type, y = price)) +
  geom_boxplot() +
  xlab("Room Type") +
  ylab("Price") +
  ggtitle("Price Distribution by Room Type")

# Calculate the count and percentage of listings in each neighborhood group
neighbourhood_counts <- airbnb %>%
  group_by(neighbourhood.group) %>%
  summarise(count = n()) %>%
  mutate(percentage = count / sum(count) * 100)

# Create a pie chart
ggplot(neighbourhood_counts, aes(x = "", y = count, fill = neighbourhood.group)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  labs(title = "Price Distribution by Neighborhood Group", fill = "Neighborhood Group") +
  geom_text(aes(label = paste0(round(percentage), "%")), position = position_stack(vjust = 0.5)) +
  theme_void() +
  theme(legend.position = "right")

# Calculate the count and percentage of listings in each room type
room_counts <- airbnb %>%
  group_by(room.type) %>%
  summarise(count = n()) %>%
  mutate(percentage = count / sum(count) * 100)

# Create a pie chart
ggplot(room_counts, aes(x = "", y = count, fill = room.type)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  labs(title = "Price Distribution by Room Type", fill = "Room Type") +
  geom_text(aes(label = paste0(round(percentage), "%")), position = position_stack(vjust = 0.5)) +
  theme_void() +
  theme(legend.position = "right")

# Author
Kai Shih Wang
