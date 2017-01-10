sql <- "
          SELECT 
          		b.Ad_ID
          ,[Targeting_Name]
          ,[Targeting_Option_Name]
          FROM [DataWarehouse_DDM].[dbo].[OO_Sales_Line_Item_Targeting] A
          JOIN [DataWarehouse_DDM].[dbo].[V_Ad_ID_Map] B on a.Sales_Order_Line_Item_ID = b.Sales_Order_Line_Item_ID
          join OO_Sales_Order_Line_Items c on a.Sales_Order_Line_Item_ID = c.Sales_Order_Line_Item_ID
          
          where c.Product_Name like '%YW%'
          or c.Product_Name like '%BTOL%'
"







#x <- OAS_listCampPerSites()

# here a mix of brand/class
camp <- '6622-1_12370_LauderdaleMarina_BTOL-SR-300x250_Feb_BWTender'
r <- oas_read(credentials=oasAuth(), request_type='Campaign', id= camp)
r$Response$Campaign$Target


# here is a DMA and a couple of brand/class
camp <- '6972-1_12384_GageMarine_BTOL-DT-728x90_Monterey'
r <- oas_read(credentials=oasAuth(), request_type='Campaign', id= camp)
r$Response$Campaign$Target

# here is a DMA and a couple of brand/class
camp <- '8382-1_12417_AugustaMarine_BTOL-SR-T728x90_Ranger_Nov'
r <- oas_read(credentials=oasAuth(), request_type='Campaign', id= camp)
r$Response$Campaign$Target

length(r$Response$Campaign$Target$Dma) #6 DMAs
length(r$Response$Campaign$Target) #64 items in list

# here is a state and a couple of brand/class
camp <- '21311-1_12809_AYS_YWUS-DT-RT1-300x250_Power'
r <- oas_read(credentials=oasAuth(), request_type='Campaign', id= camp)
r$Response$Campaign$Target

length(r$Response$Campaign$Target$State) #states
length(r$Response$Campaign$Target) #64 items in list


# here is a state and a couple of brand/class
camp <- '25723-1_13096_ORY-Trident_YWUS-DT-RT2-300x250_T4'
r <- oas_read(credentials=oasAuth(), request_type='Campaign', id= camp)
r$Response$Campaign$Target


# here is a state and a couple of brand/class
camp <- '25728-1_13096_ORY-Trident_YWUS-FP-RT2-300x250'
r <- oas_read(credentials=oasAuth(), request_type='Campaign', id= camp)
r$Response$Campaign$Target

# BOATS.COM
camp <- '25682-1_13092_PrincessUSA-MClass_BO-SRDT-RT1-300x250'
r <- oas_read(credentials=oasAuth(), request_type='Campaign', id= camp)
r$Response$Campaign$Target


# BOATS.COM
camp <- '11948-1_12465_FBG_BO-US-DT-T728x90_SE_YamahaBoats_T4_Aug'
r <- oas_read(credentials=oasAuth(), request_type='Campaign', id= camp)
r$Response$Campaign$Target

camp <- '33337-1_13441_SSL_BRAND_BOEUR-SRDT-RT1-300x250'
r <- oas_read(credentials=oasAuth(), request_type='Campaign', id= camp)
r$Response$Campaign$Target
