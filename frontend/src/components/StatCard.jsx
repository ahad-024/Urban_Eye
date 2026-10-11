import { motion } from "framer-motion";

const StatCard = ({
  title,
  value,
  icon: Icon,
  color = "text-blue-600",
}) => {

  return (

    <motion.div

      initial={{
        opacity: 0,
        y: 20,
      }}

      animate={{
        opacity: 1,
        y: 0,
      }}

      transition={{
        duration: 0.4,
      }}

      className="bg-white  rounded-3xl  p-6  shadow-lg  border  border-gray-100  hover:shadow-2xl
        hover:-translate-y-1  transition-all  duration-300">

      <div className="flex items-center justify-between">

        <div>
          <p className="text-gray-500 font-medium">  {title}  </p>
          <h2 className="text-4xl font-extrabold mt-3 text-gray-800">  {value}  </h2>
        </div>


        <div className="w-16  h-16  rounded-2xl  bg-blue-50  flex  items-center  justify-center">

          <Icon className={`text-3xl  ${color}`} />

        </div>

      </div>

    </motion.div>

  );

};


export default StatCard;