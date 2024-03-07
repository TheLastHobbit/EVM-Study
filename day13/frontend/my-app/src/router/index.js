import { Routes, Route, Link } from "react-router-dom";
import Home from "pages/home";

const RoutesApp = () => {
    return (
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/market" element={<Market />} />
        <Route path="*" element={<NoMatch />} />
      </Routes>
    );
  };
  
  function NoMatch() {
    return (
      <div>
        <h2>Nothing to see here!</h2>
        <p>
          <Link to="/">Go to the home page</Link>
        </p>
      </div>
    );
  }
  
  export default RoutesApp;