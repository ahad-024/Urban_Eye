const Badge = ({children, type = "info"}) => {

  const styles = {

    success: `bg-green-100  text-green-700  border-green-200`,

    danger: `bg-red-100  text-red-700  border-red-200`,

    warning: `bg-yellow-100  text-yellow-700  border-yellow-200`,

    info: `bg-blue-100  text-blue-700  border-blue-200`,

  };


  return (

    <span
      className={`inline-flex  items-center  px-4  py-1.5  rounded-full  text-sm  font-semibold  border
        transition-all  duration-300  hover:scale-105  ${styles[type]}`}>

      {children}

    </span>

  );
};

export default Badge;