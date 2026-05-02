import { LengthMetrics, SegmentButton, SegmentButtonItemTuple, SegmentButtonOptions } from '@kit.ArkUI';
import { drawing } from '@kit.ArkGraphics2D';

@Entry
@Component
struct QuickReplyInputDeck {
  @State currentScreen: 'LOCK' | 'DECK' = 'LOCK';
  @State message: string = 'Enter your pattern';
  private patternLockController: PatternLockController = new PatternLockController();
  @State urgency: number = 50;
  @State searchText: string = '';
  @State selectedReply: string = '';
  private allReplies: string[] = ['OK, I am coming', 'On my way', 'Call you later'];
  private searchController: SearchController = new SearchController();
  private textAreaController: TextAreaController = new TextAreaController();
  @State text: string = 'Message Channel';
  @State index: number = -1;
  @State segmentOptions: SegmentButtonOptions = SegmentButtonOptions.capsule({
    buttons: [{ text: 'Quick' }, { text: 'Emoji' }] as SegmentButtonItemTuple,
    multiply: false,
    fontSize: 9,
    fontColor: '#999999',
    selectedFontSize: 10,
    selectedFontColor: Color.White,
    selectedBackgroundColor: '#ff043160',
    backgroundColor: '#1A1A1A'
  });
  @State segmentSelectedIndexes: number[] = [0];
  private fontStyleBold: TextStyle = new TextStyle({
    fontColor: Color.White,
    fontSize: LengthMetrics.vp(12),
    fontWeight: FontWeight.Bolder
  });
  private fontStyleLight: TextStyle = new TextStyle({
    fontColor: '#ff4791de',
    fontSize: LengthMetrics.vp(14),
    fontWeight: FontWeight.Bold
  });
  @State titleStyledString: MutableStyledString = new MutableStyledString('Quick Reply');
  private titleController: TextController = new TextController();
  private context: DrawingRenderingContext = new DrawingRenderingContext();

  build() {
    Stack() {
      if (this.currentScreen === 'LOCK') {
        Column() {
          Text('Welcome').fontSize(14).fontWeight(FontWeight.Bold).fontColor(Color.White).margin({ top: '10%' })
          Text(this.message).textAlign(TextAlign.Center).fontSize(10).fontColor('#AAAAAA').margin({ top: 4, bottom: 4 })

          PatternLock(this.patternLockController)
            .sideLength(140)
            .circleRadius(6)
            .pathStrokeWidth(3)
            .activeColor('#007DFF')
            .selectedColor('#007DFF')
            .pathColor('#007DFF')
            .backgroundColor('#121212')
            .autoReset(true)
            .onDotConnect((index: number) => {
              console.info(`onDotConnect index: ${index}`);
            })
            .onPatternComplete((input: Array<number>) => {
              if (input.length < 5) {
                this.message = 'Too short!';
                this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG);
              } else {
                this.patternLockController.setChallengeResult(PatternLockChallengeResult.CORRECT);
                this.message = 'Unlocked';
                setTimeout(() => {
                  this.currentScreen = 'DECK'
                }, 400);
              }
            })

          Button('Reset')
            .margin({ top: 8 })
            .height(24)
            .fontSize(10)
            .backgroundColor('#262626')
            .onClick(() => {
              this.patternLockController.reset();
              this.message = 'Set your pattern';
            })
        }.width('100%').height('100%')
      } else {
        Scroll() {
          Column({ space: 6 }) {
            Row() {
              Canvas(this.context)
                .width(10)
                .height(10)
                .margin({ right: 2 })
                .onReady(() => {
                  let brush = new drawing.Brush();
                  brush.setColor({
                    alpha: 255,
                    red: 71,
                    green: 145,
                    blue: 222
                  });

                  this.context.canvas.attachBrush(brush);
                  this.context.canvas.drawCircle(12, 12, 8);
                  this.context.canvas.detachBrush();
                  this.context.invalidate();
                })

              Text(undefined, { controller: this.titleController })
                .onAppear(() => {
                  this.titleStyledString.setStyle({
                    start: 0,
                    length: 5,
                    styledKey: StyledStringKey.FONT,
                    styledValue: this.fontStyleBold
                  });

                  this.titleStyledString.setStyle({
                    start: 6,
                    length: 5,
                    styledKey: StyledStringKey.FONT,
                    styledValue: this.fontStyleLight
                  });

                  this.titleController.setStyledString(this.titleStyledString);
                })
            }
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .margin({ top: 15, bottom: 5 })


            Select([
              { value: 'Message App', icon: $r('app.media.chat') },
              { value: 'SMS', icon: $r('app.media.sms') }
            ])
              .selected(this.index)
              .value(this.text)
              .font({ size: 10, weight: 400 })
              .fontColor(Color.White)
              .selectedOptionFont({ size: 10, weight: 500 })
              .optionFont({ size: 10, weight: 400 })
              .optionWidth(120)
              .optionHeight(120)
              .backgroundColor('#1A1A1A')
              .borderRadius(12)
              .divider({ strokeWidth: 1, color: '#333333' })
              .onSelect((index: number, text?: string) => {
                this.index = index;
                if (text) {
                  this.text = text;
                }
              })
              .width('70%')

            SegmentButton({
              options: this.segmentOptions,
              selectedIndexes: $segmentSelectedIndexes
            })
              .width('80%')
              .height(28)

            if (this.segmentSelectedIndexes[0] === 0) {
              Search({ controller: this.searchController, placeholder: 'Search...' })
                .placeholderFont({ size: 10 })
                .textFont({ size: 10 })
                .width('80%')
                .height(30)
                .onChange((value: string) => {
                  this.searchText = value.toLowerCase();
                })
                .onFocus(() => {
                  this.searchController.setTextSelection(0, this.searchText.length, {
                    menuPolicy: MenuPolicy.SHOW
                  });
                })
                .onCopy((value: string) => {
                  console.info(`Searched text copied: ${value}`);
                })

              Column({ space: 4 }) {
                ForEach(this.allReplies.filter(item => item.toLowerCase().includes(this.searchText)),
                  (item: string) => {
                    Text(item)
                      .fontSize(10)
                      .fontColor(Color.White)
                      .textAlign(TextAlign.Center)
                      .width('80%')
                      .padding(6)
                      .backgroundColor('#333333')
                      .borderRadius(8)
                      .onClick(() => {
                        this.selectedReply = item;
                      })
                  }, (item: string) => item
                )
              }
              .width('100%')
            } else {
              Row({ space: 15 }) {
                Text('👍').fontSize(18).onClick(() => this.selectedReply += '👍')
                Text('😊').fontSize(18).onClick(() => this.selectedReply += '😊')
                Text('❤️').fontSize(18).onClick(() => this.selectedReply += '❤️')
              }.margin(5)
            }

            TextArea({ text: this.selectedReply, controller: this.textAreaController, placeholder: 'Message...' })
              .height(45)
              .width('75%')
              .fontSize(10)
              .placeholderFont({ size: 10 })
              .backgroundColor('#1A1A1A')
              .fontColor(Color.White)
              .border({ width: 1 })
              .contentType(ContentType.EMAIL_ADDRESS)
              .enableAutoFill(true)
              .onFocus(() => {
                this.textAreaController.setTextSelection(0, this.selectedReply.length, {
                  menuPolicy: MenuPolicy.SHOW
                });
              })
              .onTextSelectionChange((start: number, end: number) => {
                console.info(`Selection: ${start} - ${end}`);
              })

            Column({ space: 2 }) {
              Text(`Urgency: %${this.urgency}`)
                .fontSize(10)
                .fontColor(this.urgency > 70 ? Color.Red : '#AAAAAA')
                .fontWeight(FontWeight.Medium)

              Slider({ value: this.urgency, min: 0, max: 100 })
                .height(15)
                .width('85%')
                .blockColor(this.urgency > 70 ? Color.Red : Color.Blue)
                .trackColor('#333333')
                .selectedColor(this.urgency > 70 ? Color.Red : Color.Blue)
                .onChange((val) => {
                  this.urgency = Math.floor(val)
                })
                .enableHapticFeedback(true)
            }
            .margin({ top: 5, bottom: 5 })

            Button('Send')
              .width('50%')
              .height(28)
              .fontSize(11)
              .backgroundColor(Color.Blue)
              .onClick(() => {
                this.currentScreen = 'LOCK'
              })

            Text('Lock').fontSize(10).fontColor(Color.Red).margin({ bottom: 20 })
              .onClick(() => {
                this.currentScreen = 'LOCK'
              })
          }.width('100%')
        }
        .scrollBar(BarState.Off).width('100%').height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}