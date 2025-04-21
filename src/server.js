const express = require('express');
const dotenv = require('dotenv');
const customerDetails = require('./routes/customerDetails');
const appService = require('./services/appService')
const cors = require('cors');
const db = require('./config/db');

dotenv.config();

const app = express();

app.use(cors({
    origin: 'http://localhost:3000',  
    methods: ['GET', 'POST', 'PUT', 'DELETE'],  
    credentials: true,  
  }));
  

  app.use(express.json());
  app.use('/api/customers', customerDetails);
  app.use('/api/services', appService);

const PORT = process.env.PORT || process.env.APP_PORT;

db.connect((err) => {
  if (err) {
      console.error('Database connection error:', err.message);
  } else {
      console.log('Database connected successfully');
  }
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

