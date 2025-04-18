const express = require('express');
const dotenv = require('dotenv');
const customerDetails = require('./routes/customerDetails');
const appService = require('./services/appService')
const cors = require('cors');

dotenv.config();

const app = express();

app.use(cors({
    origin: 'http://localhost:3000',  
    methods: ['GET', 'POST', 'PUT', 'DELETE'],  
    credentials: true,  
  }));
  

app.use(express.json());  
app.use(customerDetails);  
app.use(appService);

const PORT = process.env.PORT || process.env.BACKEND_PORT;

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
