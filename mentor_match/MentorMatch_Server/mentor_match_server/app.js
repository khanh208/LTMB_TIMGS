const express = require('express');
const cors = require('cors');
require('dotenv').config();
const path = require('path'); 
const app = express();
const PORT = process.env.PORT || 3000;

require('./config/db'); 

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const tutorRoutes = require('./routes/tutorRoutes');
const scheduleRoutes = require('./routes/scheduleRoutes');
const chatRoutes = require('./routes/chatRoutes');
const subjectRoutes = require('./routes/subjectRoutes');
const reviewRoutes = require('./routes/reviewRoutes');
const walletRoutes = require('./routes/walletRoutes');
const adminRoutes = require('./routes/adminRoutes');
app.use('/admin', express.static(path.join(__dirname, 'public/admin')));
app.use(express.json({ limit: '50mb' })); 
app.use(express.urlencoded({ limit: '50mb', extended: true }));

app.use(cors());
app.use(express.json());  

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/tutors', tutorRoutes);
app.use('/api/schedule', scheduleRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/subjects', subjectRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/admin', adminRoutes);

app.get('/', (req, res) => {
  res.send('Chào mừng đến với MentorMatch API v1!');
});

app.listen(PORT, () => {
  console.log(`🚀 Server đang chạy trên http://localhost:${PORT}`);
}); 