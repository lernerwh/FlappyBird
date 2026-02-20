import { GameViewModel } from '../../viewmodel/GameViewModel';
import { ScoreRepository } from '../../model/repository/ScoreRepository';
import { common } from '@kit.AbilityKit';

/**
 * 首页 - 开始游戏、显示最高分
 */
@Entry
@Component
struct HomePage {
  @State highScore: number = 0;
  private scoreRepository: ScoreRepository | null = null;

  build() {
    Column() {
      // 标题
      Text('Flappy Bird')
        .fontSize(48)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFD700')
        .textShadow({
          radius: 4,
          color: '#000000',
          offsetX: 2,
          offsetY: 2
        })
        .margin({ top: 100, bottom: 20 })

      // 小鸟图标
      Text('🐦')
        .fontSize(80)
        .margin({ bottom: 40 })

      // 最高分
      Text(`最高分: ${this.highScore}`)
        .fontSize(24)
        .fontColor('#333333')
        .margin({ bottom: 60 })

      // 开始游戏按钮
      Button('开始游戏')
        .fontSize(24)
        .fontColor('#FFFFFF')
        .backgroundColor('#228B22')
        .borderRadius(25)
        .width(200)
        .height(50)
        .onClick(() => {
          this.onStartGame();
        })

      // 说明文字
      Text('点击屏幕让小鸟跳跃\n避开管道获得分数')
        .fontSize(16)
        .fontColor('#666666')
        .textAlign(TextAlign.Center)
        .margin({ top: 40 })
        .lineHeight(24)
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [['#87CEEB', 0.0], ['#98FB98', 1.0]]
    })
    .aboutToAppear(() => {
      this.loadHighScore();
    })
  }

  /**
   * 加载最高分
   */
  private async loadHighScore(): Promise<void> {
    try {
      const context = getContext(this) as common.UIAbilityContext;
      this.scoreRepository = new ScoreRepository(context);
      await this.scoreRepository.init();
      this.highScore = await this.scoreRepository.getHighScore();
    } catch (error) {
      console.error('Failed to load high score:', error);
    }
  }

  /**
   * 开始游戏
   */
  private onStartGame(): void {
    // 导航到游戏页面
    if (this.scoreRepository) {
      // 将 ScoreRepository 传递给 GamePage
      // 在 HarmonyOS 中，可以使用 AppStorage 或者全局状态管理来传递
      AppStorage.setOrCreate('scoreRepository', this.scoreRepository);
    }
    // 使用路由导航到游戏页面
    // 注意：需要在路由配置中添加 GamePage
  }
}
