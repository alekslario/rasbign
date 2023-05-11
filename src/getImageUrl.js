import puppeteer from "puppeteer";
import solver from "./solver.js";
const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
// const prompt = "harry potter vampire--ar 21:9 --v 5";
const password = process.env.DISCORD_PASSWORD;
const email = process.env.DISCORD_EMAIL;
const server_name = process.env.DISCORD_SERVER_NAME;

export default async (prompt) => {
  const browser = await puppeteer.launch({
    headless: true,
    ignoreHTTPSErrors: true,
    slowMo: 0,
    args: [
      "--disable-gpu",
      "--disable-dev-shm-usage",
      "--disable-setuid-sandbox",
      "--no-first-run",
      "--no-sandbox",
      "--no-zygote",
    ],
  });
  const page = await browser.newPage();
  await page.setUserAgent(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"
  );
  await page.goto("https://discord.com/login");
  // Set screen size
  await page.setViewport({ width: 1080, height: 1024 });
  await page.waitForSelector('input[name="email"]');
  //wait for js
  await wait(1000);
  await page.type('input[name="email"]', email);
  await wait(1000);
  await page.type('input[name="password"]', password);
  await wait(2000);
  try {
    await page.click('button[type="submit"]');
    let foundElement = await page.waitForSelector(
      `iframe[data-hcaptcha-widget-id], div[data-dnd-name="${server_name}"]`
    );
    //let's determine what we found
    const tagName = await foundElement.evaluate((el) => el.tagName);
    if (tagName === "IFRAME") {
      const srcString = await foundElement.evaluate((el) => el.src);
      const siteKey = srcString.split("sitekey=")[1].split("&")[0];
      const data = await solver(siteKey, "https://discord.com/login");
      await page.evaluate((token) => {
        const node =
          document.querySelector("iframe").parentElement.parentElement;
        const properties = Object.getOwnPropertyDescriptors(node);
        const keys = Object.keys(properties);
        const reactProp = keys[1];
        document
          .querySelector("iframe")
          .parentElement.parentElement[reactProp].children.props.onVerify(
            token
          );
      }, data);
      foundElement = await page.waitForSelector(
        `div[data-dnd-name="${server_name}"]`
      );
    }

    //wait for js
    await wait(1000);
    await foundElement.click();

    //default wait time is 30 seconds
    await page.waitForSelector("form");
    await page.type("form", `/imagine`);
    await wait(1000);
    await page.type("form", ` `);
    await wait(1000);
    await page.type("form", `${prompt}`);
    await page.keyboard.press("Enter");
    // wait for js to update html tree
    await wait(3000);
    await page.waitForSelector('ol li:last-of-type img[alt="🔄"]', {
      timeout: 1000 * 60 * 4,
    });
    const button = await page.waitForSelector("ol li:last-of-type button");
    //wait for javascript, buttons are not responsive at first
    await wait(3000);
    await button.click();
    //wait for upscale
    await page.waitForSelector('ol li:last-of-type img[alt="❤️"]', {
      timeout: 1000 * 60 * 4,
    });
    await wait(1000);
    const image = await page.$('ol li:last-of-type img[alt="Image"]');
    const imageSrc = await image.evaluate((img) => img.src);
    await browser.close();
    return imageSrc;
  } catch (error) {
    //sending image for debugging
    const img = await page.screenshot({ encoding: "base64" });
    const body = await page.evaluate(() => document.body.innerHTML);
    await browser.close();
    return "puppeteer error: " + error + "😀" + body + "😀" + img;
  }
};
