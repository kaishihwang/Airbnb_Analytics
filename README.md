# Analyzing Trends and Patterns of Airbnb Rentals in New York City

Summary:

Airbnb has become a popular vacation rental alternative in the United States. With the uprising of traveling nationwide, visitors are able to rent a variety of different rentals from both commercial and noncommercial homeowners. With room sizes ranging from shared rooms to entire house rentals, Airbnb services have not only allowed travelers to have the flexibility of a vacation stay of their dreams but also become one of the most desirable types of rentals. In this project, I analyzed the trends and patterns of Airbnb rentals in New York.

I sourced a dataset from Kaggle, a large Airbnb rental dataset for analysis. The dataset contains a total of 102,598 records and 26 different variables, including neighborhood groups and geographical data. The dataset is frequently updated every quarter and provides my analysis with a high timeliness factor. This means the analysis will be applicable to the current time. However, the dataset was not ready to use right out of the box, and I had to do a lot of cleaning such as removing columns that contained too many NaN values before making my analysis. I analyzed the data using various stats and visualizations. Finally, I exported the data as a CSV and also stored it in a database using SQLite.

Key findings about the data:

I compared the neighborhood process and found the top and bottom 3 neighborhoods based on revenue and room type. I also created a bar chart for the number of rentals based on borough. A bar chart showing the count of the number of room types also helped to analyze different kinds of inventory. The top 10 neighborhoods based on the number of rentals are presented in a bar chart.

Information about the dataset:

The dataset of Airbnb rentals is for one quarter from June 1, 2022, to September 30, 2022. The source of the dataset is Kaggle.com. This data gets updated every quarter. It has 102,598 records and 26 columns. The data is not clean and has many issues like null values, NaN, incorrect data type, and $ sign in amount columns.

## Map Visualization

To provide a spatial perspective, I utilized the leaflet package to create an interactive city map. The map displayed the median prices based on neighborhood group and room type, with color coding showing the price quartiles. Users can easily click on markers on the map for information such as the borough, room type, and pricing.

![Picture1](https://github.com/kaishihwang/Airbnb_Analytics/assets/131721638/030d9fc6-db27-4230-a2ed-f3700bc5bf19)
