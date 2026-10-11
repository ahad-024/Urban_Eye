import Badge from "./Badge";
import {FaMapMarkerAlt,FaCalendarAlt,FaChevronRight} from "react-icons/fa";

const ReportCard = ({
  image,
  issueType,
  location,
  date,
  severity,
  status,
  onClick,
}) => {

  const badgeType = {
    Pending: "warning",
    Resolved: "success",
    Rejected: "danger",
  };

  const severityColor = {
    High: "text-red-600",
    Medium: "text-yellow-600",
    Low: "text-green-600",
  };


  return (
    <div onClick={onClick}  className="bg-white rounded-2xl shadow-md hover:shadow-xl transition cursor-pointer overflow-hidden">


      <img src={image}  alt={issueType}  className="w-full h-52 object-cover"/>


      <div className="p-5">

        <div className="flex justify-between items-center">

          <h2 className="text-xl font-bold">  {issueType}  </h2>

          <Badge type={badgeType[status]}>  {status}  </Badge>

        </div>

        <div className="flex items-center text-gray-500 mt-4">
          <FaMapMarkerAlt className="mr-2" />
          {location}
        </div>

        <div className="flex items-center text-gray-500 mt-2">
          <FaCalendarAlt className="mr-2" />
          {date}
        </div>

        <div className="flex justify-between items-center mt-6">
          <span className={`font-semibold ${severityColor[severity]}`}>  {severity} Severity  </span>
          <FaChevronRight className="text-blue-600" />
        </div>

      </div>

    </div>
  );
};

export default ReportCard;