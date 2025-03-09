import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const nftGramLogicModule = buildModule("NFTGramLogicModule", (m) => {
  
    const nftGramLogic = m.contract("NFTGram", []);

    m.call(nftGramLogic, "initialize", []);

    return { nftGramLogic };
});

export default nftGramLogicModule;
