require('dotenv').config();

const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();

app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const AUTH_SERVICE_URL = process.env.AUTH_SERVICE_URL || 'http://localhost:4000';

app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Currency Compass API Gateway is running.',
  });
});

app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'API Gateway healthy.',
  });
});

app.post('/api/auth/register', async (req, res) => {
  try {
    const response = await axios.post(
      `${AUTH_SERVICE_URL}/api/auth/register`,
      req.body,
      {
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    return res.status(response.status).json(response.data);
  } catch (error) {
    return handleProxyError(error, res);
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const response = await axios.post(
      `${AUTH_SERVICE_URL}/api/auth/login`,
      req.body,
      {
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    return res.status(response.status).json(response.data);
  } catch (error) {
    return handleProxyError(error, res);
  }
});

app.get('/api/auth/me', async (req, res) => {
  try {
    const response = await axios.get(`${AUTH_SERVICE_URL}/api/auth/me`, {
      headers: {
        'Content-Type': 'application/json',
        Authorization: req.headers.authorization || '',
      },
    });

    return res.status(response.status).json(response.data);
  } catch (error) {
    return handleProxyError(error, res);
  }
});

function handleProxyError(error, res) {
  if (error.response) {
    return res.status(error.response.status).json(error.response.data);
  }

  return res.status(500).json({
    success: false,
    message: 'API Gateway error. Auth service is not reachable.',
  });
}

app.listen(PORT, () => {
  console.log(`API Gateway running on http://localhost:${PORT}`);
  console.log(`Forwarding auth requests to ${AUTH_SERVICE_URL}`);
});