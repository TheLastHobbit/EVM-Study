import React, { useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import '../App.css'; // Make sure you have the CSS file for styling

function UploadImage({ address }) {
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const fileInputRef = useRef(null);
  const navigate = useNavigate();

  const handleCancel = () => {
    // Reset the form or specific form fields
    setTitle('');
    setDescription('');
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
  };

  const handleUpload = async (event) => {
    event.preventDefault(); // Prevent the default form submission

    if (fileInputRef.current.files.length === 0) {
      alert('Please select a file to upload.');
      return;
    }

    const formData = new FormData();
    formData.append('title', title);
    formData.append('description', description);
    formData.append('file', fileInputRef.current.files[0]);
    formData.append('address', address);

    try {
      const response = await axios.post('http://127.0.0.1:3000/upload', formData, {
        headers: {
          'Content-Type': 'multipart/form-data'
        }
      });

      // Handle the response from the server here
      console.log('File uploaded successfully', response.data);
      navigate('/success');
    } catch (error) {
      // Handle the error here
      console.error('Error uploading file:', error);
      alert('An error occurred while uploading the file. Please try again.');
      navigate('/error');
    }
  };

  return (
    <div className="upload-container">
      <h1>Upload Image to IPFS and Mint NFT</h1>
      <form className="upload-form" onSubmit={handleUpload}>
        <label htmlFor="title">Title *</label>
        <input 
          type="text" 
          id="title" 
          placeholder="Enter image title" 
          value={title} 
          onChange={(e) => setTitle(e.target.value)}
          required 
        />

        <label htmlFor="description">Description</label>
        <textarea 
          id="description" 
          placeholder="Describe your image" 
          value={description} 
          onChange={(e) => setDescription(e.target.value)}
        />

        <label htmlFor="file">Image *</label>
        <input 
          type="file" 
          id="file" 
          ref={fileInputRef} 
          required 
        />

        <div className="buttons">
          <button type="button" className="cancel-button" onClick={handleCancel}>Cancel</button>
          <button type="submit" className="upload-button">Upload</button>
        </div>
      </form>
    </div>
  );
}

export default UploadImage;
