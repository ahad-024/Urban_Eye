const Input = ({
  label,
  type = "text",
  placeholder,
  icon: Icon,
  value,
  onChange,
  name,
}) => {

  return (
    <div className="mb-5">
      {label && (<label className="block mb-2 text-sm font-semibold text-gray-700">   {label}   </label>)}

      <div className="flex items-center rounded-xl border border-gray-300 bg-white px-4 py-3 transition-all duration-300 focus-within:border-blue-600 focus-within:ring-2 focus-within:ring-blue-200">
        {Icon && <Icon className="mr-3 text-gray-400 text-lg" />}

        <input type={type}  name={name}  value={value}  onChange={onChange}  placeholder={placeholder}
        className="w-full bg-transparent outline-none text-gray-700 placeholder-gray-400" />

      </div>

    </div>
  );
};

export default Input;