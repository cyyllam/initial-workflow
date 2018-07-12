library(RMySQL)
# library(dplyr)
library(plotly)
library(tidyverse)

un <- .rs.askForPassword("username:")
psswd <- .rs.askForPassword("password:")
h <- .rs.askForPassword("host:")
mydb <- dbConnect(MySQL(),
                 user = un,
                 password = psswd,
                 dbname = 'run_8_2017_10_31_14_10_2040',
                 host = h)

# mydb <- src_mysql(#MySQL(),
#                   user = un,
#                   password = psswd,
#                   dbname = 'run_8_2017_10_31_14_10_2040',
#                   host = h)
# 
# data <- tbl(mydb, "development_project_proposals_2015")

# List tables in the database
dbListTables(mydb)

# List fields in a table
dbListFields(mydb, 'development_project_proposals_2015')

# Query
rs <- dbSendQuery(mydb, "select * from development_project_proposals_2015")

# Fetch result and store as data frame
data <- fetch(rs, n = -1)

# p <- plot_ly(data,
#              x = ~adj_land_value_per_sqft,
#              color = ~development_type,
#              type = "box")
# 
# p

subdata <- data %>%
  filter(expected_sales_price_per_sqft <= 500 & adj_land_value_per_sqft <= 500) %>%
  select(county_id, development_type, adj_land_value_per_sqft, expected_sales_price_per_sqft) %>%
  gather(value_type, value, -county_id, -development_type)

q <- ggplot(subdata, aes(development_type, value)) +
  geom_boxplot(aes(color = development_type), outlier.size = .005, notchwidth = 0.08) +
  facet_grid(county_id ~ value_type) +
  theme(axis.title.x=element_blank(),
        axis.text.x=element_text(size = 4, angle=90, vjust=0.5),
        axis.ticks.x=element_blank(),
        legend.text = element_text(size = 6),
        legend.title = element_text(size = 8)
        ) +
  guides(col = guide_legend(nrow=21)) +
  scale_y_continuous(labels = scales::comma) 
  

q

# subdata <- data %>%
#   filter(expected_sales_price_per_sqft <= 500)
# q <- ggplot(subdata, aes(development_type, expected_sales_price_per_sqft)) +#adj_land_value_per_sqft
#   geom_boxplot(aes(color = development_type)) +
#   facet_grid(.~ county_id) +
#   theme(axis.title.x=element_blank(),
#         axis.text.x=element_blank(),
#         axis.ticks.x=element_blank(),
#         legend.text = element_text(size = 6),
#         legend.title = element_text(size = 8)) +
#   theme(legend.position = "right") +
#   guides(fill = guide_legend(ncol=1)) +
#   scale_y_continuous(name="expected_sales_price_per_sqft", labels = scales::comma)
#   
# q

# Disconnect from MySQL
dbDisconnect(mydb)
