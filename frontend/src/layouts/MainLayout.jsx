import BottomNavigation from "../components/BottomNavigation";
import { FaBell, FaUserCircle } from "react-icons/fa";

const MainLayout = ({ children }) => {
  const user = JSON.parse(localStorage.getItem("user"));

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-cyan-50 pb-24">

      <header
        className="bg-gradient-to-r from-blue-700 to-cyan-500 text-white px-6 py-6 rounded-b-[35px] shadow-xl"
      >

        <div className="flex items-center justify-between">

          <div>

            <p className="text-blue-100 text-sm">
              Welcome back 👋
            </p>

            <h1 className="text-3xl font-extrabold mt-1">
              {user?.username || "Citizen"}
            </h1>

          </div>

          <div className="flex items-center gap-4">
            <FaBell className="text-2xl cursor-pointer" />
            <FaUserCircle className="text-4xl" />
          </div>

        </div>

      </header>

      <main className="px-5 py-6 animate-fade">
        {children}
      </main>

      <BottomNavigation />

    </div>
  );
};

export default MainLayout;

