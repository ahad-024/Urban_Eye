const Card = ({
  children,
  className = "",
  maxWidth = "max-w-full",
}) => {
  return (
    <div
      className={`
        ${maxWidth}
        bg-white/90
        backdrop-blur-xl
        rounded-3xl
        shadow-lg
        border
        border-gray-100
        p-6
        transition-all
        duration-300
        hover:shadow-2xl
        hover:-translate-y-1
        ${className}
      `}>

      {children}
      
    </div>
  );
};

export default Card;