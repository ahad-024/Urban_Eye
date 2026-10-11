import { Link } from "react-router-dom";
import { FaArrowLeft } from "react-icons/fa";

const PageHeader = ({
  title,
  backTo = "/home",
  rightContent = null,
}) => {

  return (
    <div className="flex items-center justify-between mb-8">


      <div className="flex items-center gap-4">

        <Link to={backTo}
          className="w-10 h-10 rounded-full bg-white shadow flex items-center justify-center hover:bg-blue-50 transition">
          <FaArrowLeft className="text-gray-700" />
        </Link>

        <h1 className="text-3xl font-bold text-gray-800">  {title}  </h1>

      </div>


      {rightContent && (<div>  {rightContent}  </div> )}

    </div>
  );
};

export default PageHeader;