-- Upload Streamlit files to stage
USE DATABASE HOTEL_PERSONALIZATION;
USE SCHEMA STREAMLIT;
CREATE STAGE IF NOT EXISTS STAGE;

-- Upload Python files (run these commands individually in SnowSQL or use PUT from local directory)
-- PUT file://guest_360_dashboard.py @STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT file://personalization_hub.py @STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT file://amenity_performance.py @STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT file://revenue_analytics.py @STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT file://executive_overview.py @STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT file://shared/data_loader.py @STAGE/shared/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT file://shared/viz_components.py @STAGE/shared/ AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- PUT file://environment.yml @STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

LIST @STAGE;
