const LoadingSpinner = ({
  title = "Loading...",
  description = "Please wait.",
}) => {
  return (
    <div className="flex flex-col items-center justify-center py-16">


      <div className="w-16 h-16 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin"></div>


      <h2 className="mt-6 text-2xl font-bold text-gray-800">  {title}  </h2>


      <p className="mt-2 text-gray-500 text-center max-w-sm">  {description}  </p>

    </div>
  );
};

export default LoadingSpinner;