import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import NFTGramLogicModule from "./nftGramLogicModule";


const nftGramProxyModule = buildModule("DipNetMarketProxyModule", (m) => {
    
    const proxyAdminOwner = m.getAccount(0);

    const { nftGramLogic } = m.useModule(NFTGramLogicModule);

    const proxy = m.contract("DipNetMarketProxy", [
        nftGramLogic,
        proxyAdminOwner,
        "0x",
    ]);

    const proxyAdminAddress = m.readEventArgument(
        proxy,
        "AdminChanged",
        "newAdmin"
    );

    const nftGramProxyAdmin = m.contractAt("ProxyAdmin", proxyAdminAddress);

    const nftGramProxy = m.contractAt("DipNetMarket", proxy);

    m.call(nftGramProxy, "initialize", []);

    return { nftGramProxyAdmin, nftGramProxy, nftGramLogic };
});

export default nftGramProxyModule;
