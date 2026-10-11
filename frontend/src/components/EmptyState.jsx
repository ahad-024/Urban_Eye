const EmptyState = ({
  icon: Icon,
  title,
  description,
  button = null,
}) => {
  return (
    <div className="bg-white rounded-3xl shadow-md p-10 text-center">

      {Icon && (
        <div className="flex justify-center">   <Icon className="text-6xl text-blue-500 mb-5" />   </div>
      )}

      <h2 className="text-2xl font-bold text-gray-800">  {title}  </h2>

      <p className="text-gray-500 mt-3 max-w-sm mx-auto">  {description}  </p>

      {button && (
        <div className="mt-8">  {button}  </div>
      )}

    </div>
  );
};

export default EmptyState;