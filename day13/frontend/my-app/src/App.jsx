import { useEffect, useState } from 'react'
import { NetworkPlugin, ethers } from 'ethers';
import './App.css'
import { BrowserRouter } from "react-router-dom";
import AccounHeader from './components/AccounHeader'
import { RouterProvider } from "react-router-dom";
import RoutesApp from "./router/index.jsx";
import Header from "./components/header"


function App() {
  return (
    <BrowserRouter>
      <Header></Header>
      <RoutesApp />
    </BrowserRouter>
  )
}

export default App
