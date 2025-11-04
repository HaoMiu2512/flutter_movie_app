const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, '../../uploads/avatars');
console.log('📁 Avatar uploads directory:', uploadsDir);

try {
  if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, { recursive: true });
    console.log('✅ Created uploads directory');
  } else {
    console.log('✅ Uploads directory exists');
  }
} catch (error) {
  console.error('❌ Failed to create uploads directory:', error);
}

// Configure multer storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    // Generate unique filename: userId_timestamp.extension
    const userId = req.body.userId || 'unknown';
    const timestamp = Date.now();
    const ext = path.extname(file.originalname);
    cb(null, `${userId}_${timestamp}${ext}`);
  }
});

// File filter - only images
const fileFilter = (req, file, cb) => {
  console.log('🔍 Validating file:');
  console.log('   Original name:', file.originalname);
  console.log('   Mimetype:', file.mimetype);
  console.log('   Field name:', file.fieldname);
  
  const allowedMimeTypes = [
    'image/jpeg',
    'image/jpg', 
    'image/png',
    'image/gif',
    'image/webp'
  ];
  
  const allowedExtensions = /\.(jpeg|jpg|png|gif|webp)$/i;
  
  // Check mimetype first
  if (allowedMimeTypes.includes(file.mimetype.toLowerCase())) {
    console.log('✅ File type valid (mimetype)');
    return cb(null, true);
  }
  
  // Fallback: check extension
  if (allowedExtensions.test(file.originalname.toLowerCase())) {
    console.log('✅ File type valid (extension)');
    return cb(null, true);
  }
  
  console.log('❌ Invalid file type');
  cb(new Error('Only image files are allowed (jpeg, jpg, png, gif, webp)'));
};

// Configure multer upload
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB max file size
  },
  fileFilter: fileFilter
});

// Upload avatar endpoint
router.post('/avatar', (req, res) => {
  console.log('📤 Avatar upload request received');
  console.log('   Body fields:', Object.keys(req.body));
  
  upload.single('avatar')(req, res, async (err) => {
    try {
      // Handle multer errors
      if (err instanceof multer.MulterError) {
        console.error('❌ Multer error:', err);
        if (err.code === 'LIMIT_FILE_SIZE') {
          return res.status(400).json({
            success: false,
            message: 'File size too large. Maximum 5MB allowed'
          });
        }
        return res.status(400).json({
          success: false,
          message: `Upload error: ${err.message}`
        });
      } else if (err) {
        console.error('❌ Upload error:', err);
        return res.status(400).json({
          success: false,
          message: err.message || 'File upload failed'
        });
      }
      
      if (!req.file) {
        console.error('❌ No file in request');
        return res.status(400).json({ 
          success: false, 
          message: 'No file uploaded' 
        });
      }
      
      console.log('✅ File received:', req.file.filename);
      const userId = req.body.userId;
      console.log('   User ID:', userId);
      
      // Delete old avatar if exists
      if (req.body.oldAvatarPath) {
        const oldPath = path.join(__dirname, '../../', req.body.oldAvatarPath);
        if (fs.existsSync(oldPath)) {
          fs.unlinkSync(oldPath);
          console.log('🗑️  Deleted old avatar:', oldPath);
        }
      }
      
      // Generate URL for the uploaded file
      const fileUrl = `/uploads/avatars/${req.file.filename}`;
      console.log('✅ Avatar uploaded successfully:', fileUrl);
      
      res.json({ 
        success: true, 
        message: 'Avatar uploaded successfully',
        data: {
          filename: req.file.filename,
          path: fileUrl,
          url: `${req.protocol}://${req.get('host')}${fileUrl}`,
          size: req.file.size,
          mimetype: req.file.mimetype
        }
      });
      
    } catch (error) {
      console.error('❌ Avatar upload error:', error);
      console.error('   Stack:', error.stack);
      res.status(500).json({ 
        success: false, 
        message: 'Internal server error',
        error: error.message 
      });
    }
  });
});

// Delete avatar endpoint
router.delete('/avatar/:filename', async (req, res) => {
  try {
    const { filename } = req.params;
    const filePath = path.join(uploadsDir, filename);
    
    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ 
        success: false, 
        message: 'Avatar file not found' 
      });
    }
    
    fs.unlinkSync(filePath);
    
    res.json({ 
      success: true, 
      message: 'Avatar deleted successfully' 
    });
    
  } catch (error) {
    console.error('Avatar delete error:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Failed to delete avatar', 
      error: error.message 
    });
  }
});

module.exports = router;
