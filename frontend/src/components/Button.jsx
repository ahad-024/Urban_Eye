const Button = ({
  children,
  type = "button",
  variant = "primary",
  onClick,
  disabled = false,
}) => {

  const styles = {

    primary: `bg-gradient-to-r  from-blue-600  to-cyan-500  text-white  hover:from-blue-700  hover:to-cyan-600`,

    secondary: `bg-white  text-blue-600  border  border-blue-200  hover:bg-blue-50`,

    danger: `bg-gradient-to-r  from-red-500  to-orange-500  text-white  hover:from-red-600  hover:to-orange-600`,

  };


  return (

    <button type={type}  onClick={onClick}  disabled={disabled}

      className={`w-full  py-4  px-6  rounded-2xl  font-semibold  text-lg  shadow-md  transition-all  duration-300  hover:shadow-xl
      hover:-translate-y-1  active:scale-95  disabled:opacity-50  disabled:cursor-not-allowed
      ${styles[variant]} `}>

      {children}

    </button>

  );
};

export default Button;