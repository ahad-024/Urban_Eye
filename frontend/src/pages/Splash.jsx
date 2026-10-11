import { Link } from "react-router-dom";
import { FaArrowRight } from "react-icons/fa";
import logo from "../assets/logo.png";

const Splash = () => {
  return (
    <div className="min-h-screen  bg-gradient-to-br  from-blue-700  via-blue-600 
    to-sky-500  flex  flex-col  items-center  justify-center  text-white  px-6">


      <div className="w-36   h-36   rounded-full   bg-white   shadow-2xl   flex 
      items-center   justify-center  overflow-hidden">

        <img  src={logo}  alt="UrbanEye Logo" className="w-full   h-full   object-contain"/>

      </div>
 

      <h1 className="mt-8 text-5xl font-extrabold tracking-wide">  UrbanEye  </h1>


      <p className="mt-3  text-lg  text-blue-100  text-center  max-w-md">

        AI-Powered Civic Issue Detection & Smart Complaint Reporting System

      </p>
 

      <p className="mt-6  text-center  text-blue-50  max-w-lg  leading-7">

        Detect potholes, garbage, road damage, street lights, and water
        overflow using Artificial Intelligence and report them instantly
        to help build smarter cities.

      </p>


      <Link to="/register" className="mt-12">

        <button className="bg-white  text-blue-700  px-8  py-4  rounded-2xl  font-bold 
        text-lg  shadow-lg  hover:bg-gray-100  transition-all  duration-300  flex  items-center  gap-3">

          Get Started

          <FaArrowRight />

        </button>

      </Link>

    </div>
  );
};

export default Splash;