const subjectModel = require('../models/subjectModel');

const getAllSubjects = async () => {
  return await subjectModel.findAll();
};

module.exports = {
  getAllSubjects,
};  