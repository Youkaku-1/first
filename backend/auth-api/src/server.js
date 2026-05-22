require('dotenv').config();

const express = require('express');
const cors = require('cors');

const connectDB = require('./config/db');
const authRoutes = require('./routes/authRoutes');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Currency Compass Auth API is running.',
  });
});

app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Auth API healthy.',
  });
});

app.use('/api/auth', authRoutes);

const PORT = process.env.PORT || 4000;

connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`Auth API running on http://localhost:${PORT}`);
  });
});