exports.handler = async (event) => {
  console.log(event);
  let { name, age } = event;
  return createString(name, age);
};

const createString = (name, age) => {
  return `Hi ${name}, you are ${age} years old.`;
};
