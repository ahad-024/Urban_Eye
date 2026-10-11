import { useState } from "react";
import { FaEye, FaEyeSlash } from "react-icons/fa";

const PasswordInput = ({
  label,
  placeholder,
  icon: Icon,
  value,
  onChange,
  name,
}) => {
  const [showPassword, setShowPassword] = useState(false);


  return (
    <div className="mb-5">
      {label && (<label className="block mb-2 text-sm font-semibold text-gray-700">  {label}  </label> )}

      <div className="flex items-center rounded-xl border border-gray-300 bg-white px-4 py-3 transition-all duration-300 focus-within:border-blue-600 focus-within:ring-2 focus-within:ring-blue-200">
        {Icon && <Icon className="mr-3 text-lg text-gray-400" />}

        <input
          type={showPassword ? "text" : "password"}  name={name}  value={value}  onChange={onChange}
          placeholder={placeholder}  className="w-full bg-transparent outline-none text-gray-700 placeholder-gray-400"
        />

        <button type="button"  onClick={() => setShowPassword(!showPassword)}  className="ml-3 text-gray-500 hover:text-blue-600 transition">
          {showPassword ? <FaEyeSlash /> : <FaEye />}
        </button>

      </div>
    </div>
  );
};

export default PasswordInput;