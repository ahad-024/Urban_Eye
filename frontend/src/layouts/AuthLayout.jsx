const AuthLayout = ({ title, subtitle, children }) => {
  return (

    <div className="min-h-screen bg-slate-100 flex items-center justify-center p-6">

      <div className="w-full max-w-6xl bg-white rounded-3xl shadow-2xl overflow-hidden grid md:grid-cols-2">
 

        <div className="hidden md:flex flex-col items-center justify-center bg-gradient-to-br from-blue-600 to-sky-500 text-white p-10">

          <div className="w-32 h-32 rounded-full bg-white/20 flex items-center justify-center text-6xl">
            👁️
          </div>

          <h1 className="text-4xl font-bold mt-8">  UrbanEye  </h1>

          <p className="mt-4 text-center leading-7 text-blue-100">  AI-powered civic issue detection for smarter cities.  </p>

        </div>


        <div className="p-10 flex items-center justify-center">

          <div className="w-full max-w-md">
            <h2 className="text-3xl font-bold text-gray-800">  {title}  </h2>
            <p className="text-gray-500 mt-2 mb-8">  {subtitle}  </p>
            {children}
          </div>

        </div>

      </div>
    </div>
  );
};

export default AuthLayout;