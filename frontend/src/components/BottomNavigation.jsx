import { NavLink } from "react-router-dom";
import {FaHome,FaCamera,FaChartBar,FaFileAlt,FaUser} from "react-icons/fa";

const BottomNavigation = () => {

  const menus = [

    {name: "Home",  icon: FaHome,  path: "/home"},
    {name: "Capture",  icon: FaCamera,  path: "/capture"},
    {name: "Dashboard",  icon: FaChartBar,  path: "/dashboard"},
    {name: "Reports",  icon: FaFileAlt,  path: "/reports"},
    {name: "Profile",  icon: FaUser,  path: "/profile"},

  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white border-t shadow-lg">

      <div className="flex justify-around py-3">

        {menus.map((item) => {

          const Icon = item.icon;

          return (

            <NavLink key={item.path}  to={item.path}  className={({ isActive }) => `flex flex-col items-center text-xs
             ${isActive ? "text-blue-600" : "text-gray-500"}`}>
              <Icon className="text-xl mb-1" />

              {item.name}

            </NavLink>
          );
        })}

      </div>
    </nav>
  );
};

export default BottomNavigation;