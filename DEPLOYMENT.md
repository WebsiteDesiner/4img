# X413 NFT 项目部署指南

## 📋 部署前准备

### 1. 环境要求
- Node.js 16+ 
- npm 或 yarn
- MetaMask 钱包
- BNB (用于支付gas费)

### 2. 安装依赖
```bash
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers
npm install @openzeppelin/contracts
```

### 3. 准备NFT图片
- 创建5种NFT图片 (400x400px)
- 上传到IPFS获取哈希值
- 更新 `deploy-config.js` 中的图片哈希

## 🚀 部署步骤

### 步骤1: 配置网络
1. 在MetaMask中添加BSC网络
2. 获取测试网BNB (测试网水龙头)
3. 更新 `deploy-config.js` 中的私钥

### 步骤2: 部署合约
```bash
# 编译合约
npx hardhat compile

# 部署到BSC测试网
npx hardhat run scripts/deploy.js --network bscTestnet

# 部署到BSC主网
npx hardhat run scripts/deploy.js --network bsc
```

### 步骤3: 验证合约
```bash
# 在BSCScan上验证合约
npx hardhat verify --network bsc <合约地址> <构造函数参数>
```

### 步骤4: 更新前端配置
1. 更新 `index.html` 中的 `CONTRACT_ADDRESS`
2. 更新OpenSea集合链接
3. 更新网站域名

## 📝 部署后配置

### 1. 更新合约图片
```javascript
// 调用合约的 updateTypeImage 函数
await contract.updateTypeImage(0, "QmYourActualHash"); // Genesis Breaker
await contract.updateTypeImage(1, "QmYourActualHash"); // Cyber Overflow
// ... 其他NFT类型
```

### 2. 设置OpenSea集合
1. 访问 [OpenSea](https://opensea.io)
2. 创建新集合
3. 上传集合图片和描述
4. 设置版税 (建议2.5%)

### 3. 更新网站
1. 更新 `index.html` 中的合约地址
2. 更新OpenSea链接
3. 部署到GitHub Pages或Vercel

## 🔧 重要配置项

### 合约配置
- `MAX_SUPPLY`: 10000 (最大供应量)
- `MAX_PER_WALLET`: 20 (每个钱包最大持有量)
- `mintingEnabled`: true (是否开启铸造)

### 网络配置
- **BSC主网**: Chain ID 56
- **BSC测试网**: Chain ID 97

## ⚠️ 注意事项

1. **私钥安全**: 永远不要在代码中硬编码私钥
2. **测试先行**: 先在测试网部署和测试
3. **Gas费**: 主网部署需要BNB支付gas费
4. **IPFS**: 确保图片已上传到IPFS并可以访问
5. **验证**: 部署后务必在BSCScan上验证合约

## 📞 支持

如果遇到问题，请检查：
1. 网络连接是否正常
2. 钱包是否有足够的BNB
3. 合约代码是否正确编译
4. IPFS哈希是否正确

## 🎯 下一步

部署完成后：
1. 测试铸造功能
2. 在OpenSea上查看NFT
3. 分享给社区
4. 监控合约状态

