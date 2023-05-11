import captcha from "2captcha";
const solver = new captcha.Solver(process.env.CAPTCHA_API_KEY);

export default async (siteKey, url) => {
  const obj = await solver.hcaptcha(siteKey, url);
  const { data } = obj;
  return data;
};
