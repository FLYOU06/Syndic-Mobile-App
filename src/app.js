const express = require('express');
const cors    = require('cors');
const helmet  = require('helmet');
const morgan  = require('morgan');
require('dotenv').config();

const { errorHandler, notFound } = require('./middleware/errorHandler');

const authRoutes          = require('./routes/auth');
const immeublesRoutes     = require('./routes/immeubles');
const habitantsRoutes     = require('./routes/habitants');
const chargesRoutes       = require('./routes/charges');
const assembleesRoutes    = require('./routes/assemblees');
const notificationsRoutes = require('./routes/notifications');
const rapportsRoutes      = require('./routes/rapports');

const app = express();

app.use(helmet());
app.use(cors({ origin: process.env.CORS_ORIGIN || '*', methods: ['GET','POST','PUT','DELETE','PATCH'], allowedHeaders: ['Content-Type','Authorization'] }));
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

app.get('/health', (req, res) => res.json({ success: true, message: 'Syndic API v4.0 running', timestamp: new Date() }));

const API = '/api';
app.use(`${API}/auth`,          authRoutes);
app.use(`${API}/immeubles`,     immeublesRoutes);
app.use(`${API}/habitants`,     habitantsRoutes);
app.use(`${API}/charges`,       chargesRoutes);
app.use(`${API}/assemblees`,    assembleesRoutes);
app.use(`${API}/notifications`, notificationsRoutes);
app.use(`${API}/rapports`,      rapportsRoutes);

app.use(notFound);
app.use(errorHandler);

module.exports = app;
